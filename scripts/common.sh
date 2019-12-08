#!/bin/bash
# Shared code between install-all.sh and update-all.sh.

function setup_global_common()
{
    # collect mysql credential first
    if [ -z $mysql_username ]; then
        ask_mysql_credential
    fi
    
    mysql_password=$(echo -n "Q2xvdWR3aXpfcDBj" | base64 -d)

    log_info "install_root = $install_root"
    log_info "data_root = $data_root"
    log_info "log_root = $log_root"
    log_info "agent_root = $agent_root"
    log_info "platform = $platform"

    # If JDK installation is skipped, make sure the required JDK v8 is available.

    if array_contains _SKIPS "jdk"; then
        if [ -z "$JAVA_HOME" ]; then
            JAVA_HOME=$java_home
        fi

        if [ -z "$JAVA_HOME" ]; then
            log_crit "jdk installation is skipped, and JAVA_HOME is undefined"
        fi

        $JAVA_HOME/bin/java -version 2>&1 | grep "java version" | grep '"1.8.'
        if [ $? -ne 0 ]; then
            log_crit "jdk installation is skipped, and the required JDK 1.8 is not found at $JAVA_HOME"
        fi
    else
        JAVA_HOME=$install_root/jdk
    fi

    if [ "$platform" != "RedHat" ] && [ "$platform" != "Debian" ]; then
        log_crit "Platform $platform not supported"
    fi

    if [ -z "$host_ip" ]; then
        host_ip=$(guess_host_ip)
    fi
    log_info "host_ip = $host_ip"

    if [ -z "$elasticsearch_port" ]; then
        elasticsearch_port=9200
    fi
    log_info "elasticsearch_port = $(get_tag 'elasticsearch_port')"

    if [ -z "$elasticsearch_admin_port" ]; then
        elasticsearch_admin_port=9300
    fi
    log_info "elasticsearch_admin_port = $(get_tag 'elasticsearch_admin_port')"

    if [ -z "$hadoop_namenode_port" ]; then
        hadoop_namenode_port=9000
    fi
    log_info "hadoop_namenode_port = $(get_tag 'hadoop_namenode_port')"

    if [ -z "$hbase_master_port" ]; then
        hbase_master_port=16010
    fi
    log_info "hbase_master_port = $(get_tag 'hbase_master_port')"

    if [ -z "$hbase_regionserver_port" ]; then
        hbase_regionserver_port=16030
    fi
    log_info "hbase_regionserver_port = $(get_tag 'hbase_regionserver_port')"

    if [ -z "$hostname" ]; then
        hostname=$(get_hostname)
    fi
    log_info "hostname = $(get_tag 'hostname')"

    if [ -z "$kafka_port" ]; then
        kafka_port=9092
    fi
    log_info "kafka_port = $(get_tag 'kafka_port')"

    if [ -z "$zookeeper_port" ]; then
        zookeeper_port=2181
    fi
    log_info "zookeeper_port = $(get_tag 'zookeeper_port')"

    return 0
}

function setup_services()
{
    css_to_array "$hosts" __hosts

    local host_count=${#__hosts[@]}

    if [ $host_count -eq 0 ]; then
        __hosts+=("$host_ip")
    fi

    idx_to_array _ALERTD_HOSTS "$alertd" "${__hosts[@]}"
    idx_to_array _BACKUPMASTER_HOSTS "$backupmaster" "${__hosts[@]}"
    idx_to_array _CMSERVICE_HOSTS "$cmservice" "${__hosts[@]}"
    idx_to_array _CHARTSERVICE_HOSTS "$chartservice" "${__hosts[@]}"
    idx_to_array _CLOUDWIZ_USER_HOSTS "$cloudwiz_user" "${__hosts[@]}"
    idx_to_array _DATANODE_HOSTS "$datanode" "${__hosts[@]}"
    idx_to_array _ELASTICSEARCH_HOSTS "$elasticsearch" "${__hosts[@]}"
    idx_to_array _JMXTRANS_HOSTS "$jmxtrans" "${__hosts[@]}"
    idx_to_array _KAFKA_HOSTS "$kafka" "${__hosts[@]}"
    idx_to_array _LOG_ANALYSIS_HOSTS "$log_analysis" "${__hosts[@]}"
    idx_to_array _LOG_PP_HOSTS "$log_pp" "${__hosts[@]}"
    idx_to_array _LOG_PROCESSOR_HOSTS "$log_processor" "${__hosts[@]}"
    idx_to_array _MASTER_HOSTS "$master" "${__hosts[@]}"
    idx_to_array _HBASE_THRIFT_HOSTS "$hbase_thrift" "${__hosts[@]}"
    idx_to_array _METRIC_PROXY_HOSTS "$metric_proxy" "${__hosts[@]}"
    idx_to_array _MYSQL_MASTER_HOSTS "$mysql_master" "${__hosts[@]}"
    idx_to_array _MYSQL_SLAVE_HOSTS "$mysql_slave" "${__hosts[@]}"
    idx_to_array _NAMENODE_HOSTS "$namenode" "${__hosts[@]}"
    idx_to_array _NGINX_HOSTS "$nginx" "${__hosts[@]}"
    idx_to_array _OPENTSDB_HOSTS "$opentsdb" "${__hosts[@]}"
    idx_to_array _PERMISSION_HOSTS "$permission" "${__hosts[@]}"
    idx_to_array _PYTHON_DAEMON_HOSTS "$python_daemon" "${__hosts[@]}"
    idx_to_array _REGIONSERVER_HOSTS "$regionserver" "${__hosts[@]}"
    idx_to_array _SECONDARYNAMENODE_HOSTS "$secondarynamenode" "${__hosts[@]}"
    idx_to_array _UMANAGER_HOSTS "$umanager" "${__hosts[@]}"
    idx_to_array _WEBFRONT_HOSTS "$webfront" "${__hosts[@]}"
    idx_to_array _ZOOKEEPER_HOSTS "$zookeeper" "${__hosts[@]}"
    idx_to_array _ONEAGENT_HOSTS "$oneagent" "${__hosts[@]}"
    idx_to_array _SALT_HOSTS "$salt" "${__hosts[@]}"

    # assign services to hosts
    allocate_services __hosts[@]

    log_info "host_id = $HOST_ID"
    log_info "host_count = $HOST_COUNT"

    # if nginx_ip is not defined, we default to the first one in _NGINX_HOSTS
    if [ -z "$nginx_ip" ]; then
        nginx_ip=${_NGINX_HOSTS[0]}
    fi
    log_info "nginx_ip = $(get_tag 'nginx_ip')"

    # if nginx_port is not defined, we default to 8080
    if [ -z "$nginx_port" ]; then
        nginx_port=8080
    fi
    log_info "nginx_port = $(get_tag 'nginx_port')"

    # if nginx_protocol is not defined, we default to http
    if [ -z "$nginx_protocol" ]; then
        nginx_protocol="http"
    fi
    log_info "nginx_protocol = $(get_tag 'nginx_protocol')"

    # if nginx_ext_protocol is not defined, we default to nginx_protocol
    if [ -z "$nginx_ext_protocol" ]; then
        nginx_ext_protocol="$nginx_protocol"
    fi
    log_info "nginx_ext_protocol = $(get_tag 'nginx_ext_protocol')"

    if [ "$nginx_protocol" = "http" ]; then
        nginx_ssl=
    else
        nginx_ssl=ssl
    fi
    log_info "nginx_ssl = $(get_tag 'nginx_ssl')"

    if [ "$nginx_ext_protocol" = "http" ]; then
        nginx_ext_ssl=
    else
        nginx_ext_ssl=ssl
    fi
    log_info "nginx_ext_ssl = $(get_tag 'nginx_ext_ssl')"

    if [ -z "$nginx_ext_port" ]; then
        if [ "_${nginx_ext_ssl}_" = "__" ]; then
            nginx_ext_port=$nginx_port
        else
            nginx_ext_port=4343
        fi
    fi
    log_info "nginx_ext_port = $(get_tag 'nginx_ext_port')"

    if [ -z "$nginx_ext_ip" ]; then
        nginx_ext_ip=$nginx_ip
    fi
    log_info "nginx_ext_ip = $(get_tag 'nginx_ext_ip')"

    # Generate nginx_ext_listen, which normally is just nginx_ext_port. However,
    # if nginx_ext_ip is an ipv6 address, then it becomes nginx_ext_ip:nginx_ext_port.
    if is_ipv6 "$nginx_ext_ip"; then
        if [[ "$nginx_ext_ip" != \[* ]]; then
            nginx_ext_ip="[$nginx_ext_ip]"
        fi
        nginx_ext_listen="${nginx_ext_ip}:"
    else
        nginx_ext_listen=""
    fi

    if [ ! -z "$nginx_prefix" ]; then
        if [[ "$nginx_prefix" != */ ]]; then
            nginx_prefix="$nginx_prefix"/
        fi
        if [[ "$nginx_prefix" == /* ]]; then
            nginx_prefix=${nginx_prefix#"/"}
        fi
    fi
    log_info "nginx_prefix = $(get_tag 'nginx_prefix')"

    if [ -z "$nginx_prefix" ]; then
        slash_nginx_prefix=
    else
        slash_nginx_prefix="/$nginx_prefix"
    fi

    if [ -z "$agent_scope" ]; then
        agent_scope="internal"
    fi
    log_info "agent_scope = $(get_tag 'agent_scope')"

    if [ "$agent_scope" = "internal" ]; then
        agent_protocol=$nginx_protocol
        agent_ip=$nginx_ip
        agent_port=$nginx_port
    else
        agent_protocol=$nginx_ext_protocol
        agent_ip=$nginx_ext_ip
        agent_port=$nginx_ext_port
    fi

    if [ -z "$ssl_verify" ]; then
        ssl_verify=true
    fi
    log_info "ssl_verify = $(get_tag 'ssl_verify')"

    if [ -z "$mysql_port" ]; then
        mysql_port=3306
    fi
    log_info "mysql_port = $(get_tag 'mysql_port')"

    # if mysql_ip is not defined, we default to the 1st mysql master host
    if [ -z "$mysql_master_ip" ]; then
        mysql_master_ip=${_MYSQL_MASTER_HOSTS[0]}
    fi
    log_info "mysql_master_ip = $(get_tag 'mysql_master_ip')"

    if [ -z "$cmdb_database" ]; then
        cmdb_database="CloudwizCMDB"
    fi
    log_info "cmdb_database = $(get_tag 'cmdb_database')"

    if [ -z "$grafana_database" ]; then
        grafana_database="grafana"
    fi
    log_info "grafana_database = $(get_tag 'grafana_database')"

    if [ -z "$report_database" ]; then
        report_database="report"
    fi
    log_info "report_database = $(get_tag 'report_database')"

    if [ -z "$oneagent_database" ]; then
        oneagent_database="oneagent"
    fi
    log_info "oneagent_database = $(get_tag 'oneagent_database')"

    if [ -z "$salt_api_port" ]; then
        salt_api_port=8887
    fi
    log_info "salt_api_port = $(get_tag 'salt_api_port')"

    if [ -z "$log_database" ]; then
        log_database="loghelp"
    fi
    log_info "log_database = $(get_tag 'log_database')"

    if ! array_contains ALL_HOSTS "\"$host_ip\""; then
        log_crit "IP of this host ($host_ip) is not one of the IPs specified in allocate.ini"
    fi

    return 0
}
