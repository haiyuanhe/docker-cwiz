#!/bin/bash
# Assign services to hosts.

. ./utils.sh

ALL_HOSTS=
ALL_SERVICES=

function has_service()
{
    if [ "$1" == "all" ]; then
        return 0    # YES
    fi

    local _svc=${1//-/_}
    local _name="_${_svc^^}_HOSTS"
    #local _hosts="${!_name}"

    array_contains "$_name" "$host_ip"
    return $?
}

function allocate_services()
{
    declare -a HOST_IPS=("${!1}")

    HOST_COUNT=${#HOST_IPS[@]}

    if [ $HOST_COUNT -eq 0 ]; then
        log_crit "No hosts defined"
    fi

    for ip in ${HOST_IPS[@]}
    do
        ALL_HOSTS="$ALL_HOSTS \"$ip\""
    done

    HOST_IPS_COMMA_SEPARATED=
    for _h in ${HOST_IPS[@]}
    do
        HOST_IPS_COMMA_SEPARATED="${HOST_IPS_COMMA_SEPARATED}, $_h"
    done
    HOST_IPS_COMMA_SEPARATED=${HOST_IPS_COMMA_SEPARATED/, /}

    ELASTICSEARCH_HOSTS_COMMA_SEPARATED=
    for _h in ${_ELASTICSEARCH_HOSTS[@]}
    do
        ELASTICSEARCH_HOSTS_COMMA_SEPARATED="${ELASTICSEARCH_HOSTS_COMMA_SEPARATED}, \"$_h\""
    done
    ELASTICSEARCH_HOSTS_COMMA_SEPARATED=${ELASTICSEARCH_HOSTS_COMMA_SEPARATED/, /}

    if [ ${#_ELASTICSEARCH_HOSTS[@]} -gt 1 ]; then
        ELASTICSEARCH_REPLICAS=1
    else
        ELASTICSEARCH_REPLICAS=0
    fi

    HOST_IPS_NEWLINE_SEPARATED=
    for _h in ${HOST_IPS[@]}
    do
        HOST_IPS_NEWLINE_SEPARATED="${HOST_IPS_NEWLINE_SEPARATED}${_h}\n"
    done

    QUOTED_HOST_IPS_COMMA_SEPARATED=
    for _h in ${HOST_IPS[@]}
    do
        QUOTED_HOST_IPS_COMMA_SEPARATED="${QUOTED_HOST_IPS_COMMA_SEPARATED}, \"$_h\""
    done
    QUOTED_HOST_IPS_COMMA_SEPARATED=${QUOTED_HOST_IPS_COMMA_SEPARATED/, /}


    # this will include both master and backupmaster hosts
    MASTER_HOSTS=


    # set HOST_ID based on the position of host_ip in HOST_IPS[]
    index_in_array HOST_IPS "$host_ip"
    HOST_ID=$?
    HOST_ID_PLUS_ONE=$(($HOST_ID+1))


    ################################################################
    # Go through all the services, in order you want them to start #
    ################################################################

    # nginx
    if array_contains _NGINX_HOSTS "$host_ip"; then
        ALL_SERVICES="$ALL_SERVICES \"nginx\""
    fi


    # zookeeper
    ZOOKEEPER_SERVERS=
    ZOOKEEPER_SERVERS_NEWLINE_SEPARATED=
    for _h in ${_ZOOKEEPER_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"zookeeper\""
        fi
        ZOOKEEPER_SERVERS="${ZOOKEEPER_SERVERS} server ${_h}:$zookeeper_port;"
        index_in_array HOST_IPS "$_h"
        _id=$(($?+1))
        ZOOKEEPER_SERVERS_NEWLINE_SEPARATED="${ZOOKEEPER_SERVERS_NEWLINE_SEPARATED}server.$_id=$_h:2888:3888\n"
    done


    # namenode
    NAMENODE_SERVERS=
    for _h in ${_NAMENODE_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"namenode\""
        fi
        NAMENODE_IP=$_h
        NAMENODE_SERVERS="${NAMENODE_SERVERS} server ${_h}:$hadoop_namenode_port;"
    done

    if [ ${#_NAMENODE_HOSTS[@]} -ne 1 ]; then
        log_crit "There should be exactly 1 namenode host."
    fi


    # secondarynamenode
    SECONDARYNAMENODE_SERVERS=
    for _h in ${_SECONDARYNAMENODE_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"secondarynamenode\""
        fi

        if array_contains _NAMENODE_HOSTS "$_h"; then
            log_crit "Primary namenode and secondarynamenode cannot be on the same host: $_h"
        fi

        SECONDARYNAMENODE_SERVERS="${SECONDARYNAMENODE_SERVERS} server ${_h}:$hadoop_namenode_port;"
    done


    # datanode
    DATANODE_HOSTS_NEWLINE_SEPARATED=

    for _h in ${_DATANODE_HOSTS[@]}
    do
        DATANODE_HOSTS_NEWLINE_SEPARATED="${DATANODE_HOSTS_NEWLINE_SEPARATED}${_h}\n"
    done

    if array_contains _DATANODE_HOSTS "$host_ip"; then
        ALL_SERVICES="$ALL_SERVICES \"datanode\""
    fi


    # master
    MASTER_SERVERS=
    for _h in ${_MASTER_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"master\""
        fi
        MASTER_HOSTS="${MASTER_HOSTS} \"$_h\""
        MASTER_SERVERS="${MASTER_SERVERS} server ${_h}:$hbase_master_port;"
    done


    # backupmaster
    for _h in ${_BACKUPMASTER_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"backupmaster\""
        fi
        MASTER_HOSTS="${MASTER_HOSTS} \"$_h\""
    done


    # hbase_thrift
    for _h in ${_HBASE_THRIFT_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"hbase-thrift\""
        fi
        HBASE_THRIFT_SERVERS="${HBASE_THRIFT_SERVERS} server ${_h}:9090;"
    done


    # python_daemon
    for _h in ${_PYTHON_DAEMON_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"python-daemon\""
        fi
        PYTHON_DAEMON_SERVERS="${PYTHON_DAEMON_SERVERS} server ${_h}:8100;"
    done


    # regionserver
    REGIONSERVER_SERVERS=
    for _h in ${_REGIONSERVER_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"regionserver\""
        fi
        REGIONSERVER_SERVERS="${REGIONSERVER_SERVERS} server ${_h}:$hbase_regionserver_port;"
    done


    # mysql
    if [ ${#_MYSQL_MASTER_HOSTS[@]} -gt 0 ]; then
        mysql_ip=${_MYSQL_MASTER_HOSTS[0]}

        if array_contains _MYSQL_MASTER_HOSTS "$host_ip" && ! array_contains _SKIPS "mysql"; then
            ALL_SERVICES="$ALL_SERVICES \"mysql-master\""
        fi

        if array_contains _MYSQL_SLAVE_HOSTS "$host_ip" && ! array_contains _SKIPS "mysql"; then
            ALL_SERVICES="$ALL_SERVICES \"mysql-slave\""
        fi
    fi


    # oneagent
    ONEAGENT_SERVERS=
    for _h in ${_ONEAGENT_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"oneagent\""
        fi
        ONEAGENT_SERVERS="${ONEAGENT_SERVERS} server ${_h}:8888;"
    done


    # salt_api
    SALT_API_HOST=${_ONEAGENT_HOSTS[0]}


    # cmservice
    CMSERVICE_SERVERS=
    for _h in ${_CMSERVICE_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"cm-service\""
        fi
        CMSERVICE_SERVERS="${CMSERVICE_SERVERS} server ${_h}:9601;"
    done

    # chart service
    CHARTSERVICE_HOST_PORT=
    CHARTSERVICE_SERVERS=
    for _h in ${_CHARTSERVICE_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"chart-service\""
        fi
        CHARTSERVICE_SERVERS="${CHARTSERVICE_SERVERS} server ${_h}:5012;"
    done
    CHARTSERVICE_HOST_PORT="${_CHARTSERVICE_HOSTS[0]}:5012"

    # elasticsearch
    ELASTICSEARCH_KB_HOST=
    ELASTICSEARCH_HOSTS=
    ELASTICSEARCH_HOSTS_UNQUOTED=
    ELASTICSEARCH_SERVERS=
    ELASTICSEARCH_ADMIN_SERVERS=
    for _h in ${_ELASTICSEARCH_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"elasticsearch\""
        fi
        ELASTICSEARCH_HOSTS="${ELASTICSEARCH_HOSTS},\"$_h\""
        ELASTICSEARCH_HOSTS_UNQUOTED="${ELASTICSEARCH_HOSTS_UNQUOTED},$_h"
        ELASTICSEARCH_SERVERS="${ELASTICSEARCH_SERVERS} server ${_h}:$elasticsearch_port;"
        ELASTICSEARCH_ADMIN_SERVERS="${ELASTICSEARCH_ADMIN_SERVERS} server ${_h}:$elasticsearch_admin_port;"
    done
    ELASTICSEARCH_KB_HOST=${_CHARTSERVICE_HOSTS[0]}
    ELASTICSEARCH_HOSTS=(${ELASTICSEARCH_HOSTS//,/ })
    ELASTICSEARCH_HOSTS_UNQUOTED=(${ELASTICSEARCH_HOSTS_UNQUOTED//,/ })
    ELASTICSEARCH_HOST_COUNT=${#ELASTICSEARCH_HOSTS[@]}
    ELASTICSEARCH_HOST_COUNT_MINUS_ONE=$(($ELASTICSEARCH_HOST_COUNT-1))


    # kafka
    KAFKA_SERVERS=
    for _h in ${_KAFKA_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"kafka\""
        fi
        KAFKA_SERVERS="${KAFKA_SERVERS} server ${_h}:$kafka_port;"
    done
    KAFKA_HOST=${_KAFKA_HOSTS[0]}


    # log-analysis
    LOG_ANALYSIS_SERVERS=
    for _h in ${_LOG_ANALYSIS_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"log-analysis\""
        fi
        LOG_ANALYSIS_SERVERS="${LOG_ANALYSIS_SERVERS} server ${_h}:9400;"
    done


    # log-pp
    LOG_PP_SERVERS=
    for _h in ${_LOG_PP_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"log-pp\""
        fi
        LOG_PP_SERVERS="${LOG_PP_SERVERS} server ${_h}:5045;"
    done


    # log-processor
    LOG_PROCESSOR_SERVERS=
    for _h in ${_LOG_PROCESSOR_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"log-processor\""
        fi
#        LOG_PROCESSOR_SERVERS="${LOG_PROCESSOR_SERVERS} server ${_h}:9500;"
        LOG_PROCESSOR_SERVERS="${LOG_PROCESSOR_SERVERS} server ${_h}:443;"
    done


    # opentsdb
    OPENTSDB_SERVERS=
    for _h in ${_OPENTSDB_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"opentsdb\""
        fi
        OPENTSDB_SERVERS="${OPENTSDB_SERVERS} server ${_h}:4242;"
    done


    # permission
    PERMISSION_SERVERS=
    for _h in ${_PERMISSION_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"permission\""
        fi
        PERMISSION_SERVERS="${PERMISSION_SERVERS} server ${_h}:4123;"
    done


    # cloudwiz-user
    CLOUDWIZ_USER_SERVERS=
    for _h in ${_CLOUDWIZ_USER_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"cloudwiz-user\""
        fi
        CLOUDWIZ_USER_SERVERS="${CLOUDWIZ_USER_SERVERS} server ${_h}:7002;" 
    done


    # metric-proxy / metrics-kafka
    METRIC_PROXY_SERVERS=
    for _h in ${_METRIC_PROXY_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"metric-proxy\""
        fi
        METRIC_PROXY_SERVERS="${METRIC_PROXY_SERVERS} server ${_h}:4243;"
    done


    # alertd
    ALERTD_HOSTNAME=${host_ip//./_}
    ALERTD_HOSTNAMES=
    ALERTD_SERVERS=
    for _h in ${_ALERTD_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"daemon\""
        fi
        ALERTD_HOSTNAMES=${ALERTD_HOSTNAMES},${_h//./_}
        ALERTD_SERVERS="${ALERTD_SERVERS} server ${_h}:5001;"
    done
    # TODO: No idea what this is suppose to do???
    ALERTD_HOSTNAMES=${ALERTD_HOSTNAMES/,/}


    # webfront
    WEBFRONT_SERVERS=
    for _h in ${_WEBFRONT_HOSTS[@]}
    do
        if [ "$_h" == "$host_ip" ]; then
            ALL_SERVICES="$ALL_SERVICES \"webfront\""
        fi
        WEBFRONT_SERVERS="${WEBFRONT_SERVERS} server ${_h}:3000;"
    done


    # umanager
    if array_contains _UMANAGER_HOSTS "$host_ip"; then
        ALL_SERVICES="$ALL_SERVICES \"umanager\""
    fi

    # jmxtrans
    if array_contains _JMXTRANS_HOSTS "$host_ip" && ! array_contains _SKIPS "jmxtrans"; then
        ALL_SERVICES="$ALL_SERVICES \"jmxtrans\""
    fi
}
