#!/bin/bash

. ./utils.sh
. ./allocate.sh
. ./common.sh


# location of templates
_TEMPLATE=../template
_COMPONENT=
_SKIPS=()
_NO_VERIFY=0
_CLEANUP=0
_FORCE=0

# process command line arguments
while [[ $# -gt 0 ]]
do
    key=$1

    case $key in
        --as-root)
        _AS_ROOT=1
        ;;
        --cleanup)
        _CLEANUP=1
        ;;
        --debug)
        _DEBUG=1
        ;;
        --force)
        _FORCE=1
        ;;
        --no-verify)
        _NO_VERIFY=1
        ;;
        --skip)
        shift
        _SKIPS+=("$1")
        ;;
        --*)
        _COMPONENT=${key//-/}
        ;;
        *)
        # Config file
        _CFG=$key
        ;;
    esac
    shift
done

# warn if the script was run as root
USER=$(get_user)
#if [ $USER = "root" -a $_CLEANUP -eq 0 ]; then
#    log_crit "Please run as non-root!"
#fi

# if config file was not specified, default to "install.ini"
if [ -z "$_CFG" ]; then
    log_info "Using config file install.ini"
    _CFG="install.ini"
fi


function verify_environment()
{
    # make sure no previous installed processes are running
    local procs=( "supervisord" "java" "mysqld" "nginx" "node" "run-uagent.sh" "filebeat" "runner.py" "grafana-server" "gunicorn" )

    for proc in ${procs[@]}
    do
        if pgrep $proc; then
            log_crit "Process $proc is still running"
        fi
    done

    # make sure $USER is a member of the user group with the same name
    groups | grep $USER > /dev/null

    if [ $? -ne 0 ]; then
        log_crit "User $USER must be a member of the user group $USER"
    fi

    # make sure user has enough resource to run our services
    local nproc=$(get_ulimit "max user processes")
    local nofile=$(get_ulimit "open files")
    local memlock=$(get_ulimit "max locked memory")
    local maxmap=$(/sbin/sysctl -n vm.max_map_count)

    if [ "$nproc" != "unlimited" ] && [ "$nproc" -lt "4096" ]; then
        log_crit "nproc should be at least 4096 (also check nofile and memlock requirements)"
    fi

    if [ "$nofile" != "unlimited" ] && [ "$nofile" -lt "65536" ]; then
        log_crit "nofile should be at least 65536 (also check memlock requirement)"
    fi

    if [ "$memlock" != "unlimited" ]; then
        log_crit "memlock should be unlimited"
    fi

    if [ "$maxmap" -lt "262144" ]; then
        log_crit "vm.max_map_count should be at least 262144 (sysctl)"
    fi

    # make sure /etc/hosts is valid
    getent hosts 127.0.0.1 | grep -i $(hostname) > /dev/null
    if [ $? -eq 0 ]; then
        log_crit "Hostname $(hostname) is mapped to 127.0.0.1 in /etc/hosts! Please correct it."
    fi

    getent hosts 127.0.0.1 | grep localhost > /dev/null
    if [ $? -ne 0 ]; then
        log_crit "localhost not defined as 127.0.0.1 in /etc/hosts!"
    fi

    # make sure the following environment variables are NOT set
    # ES_HOME, HADOOP_HOME, HBASE_HOME, JAVA_HOME, ZK_HOME
    if [ ! -z "$ES_HOME" ]; then
        log_error "Environment variable ES_HOME is already defined as $ES_HOME. ES may not run properly!"
    fi

    if [ ! -z "$HADOOP_HOME" ]; then
        log_error "Environment variable HADOOP_HOME is already defined as $HADOOP_HOME. Hadoop may not run properly!"
    fi

    if [ ! -z "$HBASE_HOME" ]; then
        log_error "Environment variable HBASE_HOME is already defined as $HBASE_HOME. Hbase may not run properly!"
    fi

    if [ ! -z "$JAVA_HOME" ]; then
        log_error "Environment variable JAVA_HOME is already defined as $JAVA_HOME"
    fi

    if [ ! -z "$KAFKA_HOME" ]; then
        log_error "Environment variable KAFKA_HOME is already defined as $KAFKA_HOME. Kafka may not run properly!"
    fi

    if [ ! -z "$ZK_HOME" ]; then
        log_error "Environment variable ZK_HOME is already defined as $ZK_HOME. Zookeeper may not run properly!"
    fi

    # check timezone and warn if we are in the wrong timezone!
    local tz=$(date +%z)
    if [ "_$tz" != "_+0800" ]; then
        log_error "Timezone on this host is not +0800, it's metrics will be hard to find!"
    fi
}

function verify_directories()
{
    # directories to create, if necessary:
    # $install_root, $data_root, $log_root
    local dirs=()

    if ! is_parent_child "$install_root" "$data_root" && ! is_parent_child "$install_root" "$log_root"; then
        dirs+=("$install_root")
    fi

    if ! is_parent_child "$data_root" "$install_root" && ! is_parent_child "$data_root" "$log_root"; then
        dirs+=("$data_root")
    fi

    if ! is_parent_child "$log_root" "$install_root" && ! is_parent_child "$log_root" "$data_root"; then
        dirs+=("$log_root")
    fi

#    for dir in ${dirs[@]}
#    do
#        if [ ! -d $dir ]; then
#            log_info "Creating directory $dir"
#            make_dir "$dir"
#        elif ! is_dir_empty $dir; then
#            log_crit "Directory $dir not empty"
#        fi
#    done

    # install_root, data_root, and log_root have to be all different!
    if [ "$install_root" = "$data_root" ]; then
        log_crit "install_root cannot be the same as data_root"
    elif [ "$install_root" = "$log_root" ]; then
        log_crit "install_root cannot be the same as log_root"
    elif [ "$data_root" = "$log_root" ]; then
        log_crit "data_root cannot be the same as log_root"
    fi
}

function setup_global()
{
    # if cleanup is requested, do it...
    if [ $_CLEANUP -ne 0 ]; then
        do_cleanup
        exit 0
    fi

    setup_global_common

    if [ $_NO_VERIFY -eq 0 ]; then
        verify_directories
    fi

    return 0
}

function do_cleanup()
{
    log_info "Do cleanup and exit!"

    if [ $_FORCE -eq 0 ]; then
        log_error "This will kill ALL java programs, ALL nginx, ALL mysql, ALL supervisord on this host!!!"
        read -p "Are you sure [y|n]? " -n 1 -r
        echo    # (optional) move to a new line
        if [[ ! $REPLY =~ ^[Yy]$ ]]
        then
            [[ "$0" = "$BASH_SOURCE" ]] && exit 1
        fi
    fi

    # stop cloudwiz-agent, if any
    if [ -x "$agent_root/cloudwiz-agent/cloudwiz-agent" ]; then
        run_as_root "$agent_root/cloudwiz-agent/cloudwiz-agent stop"
    fi

    # stop cloudwiz-one, if any
    if [ -x "$agent_root/cloudwiz-one/cloudwiz-one.sh" ]; then
        run_as_root "$agent_root/cloudwiz-one/cloudwiz-one.sh stop"
    fi

    # stop all services
    if [ -x "$install_root/supervisord/altenv/bin/supervisorctl" ]; then
        echo "Stopping all services..."
        run_as_root "$install_root/supervisord/altenv/bin/supervisorctl stop all"
    fi

    # kill any left-overs
    pkill -9 java
    pkill -9 nginx
    pkill -9 mysqld
    pkill -9 node
    pkill -9 daemon.py
    pkill -9 run-uagent.sh
    pkill -9 grafana-server
    pkill -9 gunicorn
    pkill -9 -f filebeat
    pkill -9 -f supervisord
    pkill -9 -f clock_skew.sh
    pkill -9 -f runner.py

    # cleanup folders
    echo "cleanup folders..."
    run_as_root "rm -rf $install_root/*"
    rm -rf $data_root/*
    rm -rf $log_root/*
    rm -rf $agent_root/*

    # cleanup /tmp directory
    rm -rf /tmp/agent.tar.gz*
    rm -rf /tmp/alertd-std*
    rm -rf /tmp/backupmaster-std*
    rm -rf /tmp/chartservice-std*
    rm -rf /tmp/cloudwiz-user-std*
    rm -rf /tmp/cmservice-std*
    rm -rf /tmp/collector-std*
    rm -rf /tmp/datanode-std*
    rm -rf /tmp/elasticsearch-std*
    rm -rf /tmp/filebeat-std*
    rm -rf /tmp/hadoop-$USER
    rm -rf /tmp/hbase-$USER
    rm -rf /tmp/hbase_regionserver_info.txt
    rm -rf /tmp/hsperfdata_$USER
    rm -rf /tmp/Jetty*
    rm -rf /tmp/jmxtrans-std*
    rm -rf /tmp/jna-*
    rm -rf /tmp/kafka-std*
    rm -rf /tmp/liblz4-java*
    rm -rf /tmp/log-analysis-std*
    rm -rf /tmp/log-pp-std*
    rm -rf /tmp/log-processor-std*
    rm -rf /tmp/master-std*
    rm -rf /tmp/metric-proxy-std*
    rm -rf /tmp/mysql-master-std*
    rm -rf /tmp/mysql-slave-std*
    rm -rf /tmp/namenode-std*
    rm -rf /tmp/nginx-std*
    rm -rf /tmp/opentsdb-std*
    rm -rf /tmp/permission-std*
    rm -rf /tmp/regionserver-std*
    rm -rf /tmp/secondarynamenode-std*
    rm -rf /tmp/start_cloudwiz-std*
    rm -rf /tmp/start_dependencies-std*
    rm -rf /tmp/start_services-std*
    rm -rf /tmp/tmp.*
    rm -rf /tmp/tomcat*
    rm -rf /tmp/uagent-std*
    rm -rf /tmp/umanager-std*
    rm -rf /tmp/unpacked-*
    rm -rf /tmp/webfront-std*
    rm -rf /tmp/zookeeper-std*

    if [ -f /tmp/agent.tar.gz ]; then
        log_error "Failed to remove file /tmp/agent.tar.gz! Please remove it before re-install."
    fi

    if [ -f /tmp/agent.tar.gz.md5 ]; then
        log_error "Failed to remove file /tmp/agent.tar.gz.md5! Please remove it before re-install."
    fi

    # cleanup cron jobs
    crontab -l | grep -v "supervisord/bin/start.sh" | crontab -
    crontab -l | grep -v "cloudwiz-agent" | crontab -
    crontab -l | grep -v "run-parts $install_root/tools/cron/cron" | crontab -

    # cleanup .bashrc file
    sed -i '/\/chart-rpms\//d' ~/.bashrc
    sed -i '/supervisord\/altenv\/bin/d' ~/.bashrc

    if does_cmd_exist init; then
        chkconfig --del cloudwiz-agent
        rm -f /etc/init.d/cloudwiz-agent
    fi

    if is_systemd_running; then
        remove_systemd_service cloudwiz-agent.service
    fi

    echo "Done cleanup."
}

# install_service just for docker
function update_template(){
    local service=$1

    # if it is in _SKIPS, skip it
    if array_contains _SKIPS "$service"; then
        next_step "SKip installing $service, as requested"
        return 0
    fi

    next_step "Installing $service into $install_root"

    log_info "Updating $service templates..."

    if [ -d "$_TEMPLATE/$service" ]; then
        copy_and_replace "$_TEMPLATE/$service" "$install_root/$service"
    fi

    return 0
}


function action()
{
    local service=$1

    if [[ ! -z "$include" ]]; then
        log_debug "parsing file ${include}..."
        cfg.parser2 $include
    fi

    if [[ -z "$_COMPONENT" ]] || [[ "$_COMPONENT" = "$service" ]]; then
        if [ "$service" = "command" ]; then
            run_commands
        elif [ "$service" = "services" ]; then
            setup_services
        else
            # install regular service
            #install_service "$service"
            update_template "$service"
        fi
    fi
}


# make sure we have a clean environment
#if [ $_CLEANUP -eq 0 ]; then
#    verify_environment
#fi

# add cwiz_static_sql to template
if [ ! -f "$_TEMPLATE/tools/mysql/sql/cwiz_static.sql" ]; then
    cp -a ../mysql/cwiz_static.sql $_TEMPLATE/tools/mysql/sql/
fi

next_step "Initialization"

# read the ini file
IFS_OLD=$IFS
IFS=$'\n' read -d '' -r -a ini < "$_CFG"
IFS=$IFS_OLD

_SERVICE=

# the ini file can't have more than _MAXLINE lines
_MAXLINE=1024

for i in `seq 0 $_MAXLINE`
do
    # if EOF...
    if [ $i -eq $_MAXLINE ]; then
        action "$_SERVICE"
        break
    fi

    line="${ini[$i]}"
    line=${line##+([[:space:]])}    # trim leading spaces
    line=${line%%+([[:space:]])}    # trim trailing spaces

    # skip empty lines
    if [ -z "$line" ]; then
        continue
    fi

    # skip comment line (start with ';')
    if [[ $line = \;* ]]; then
        continue
    fi

    # check for section header: [<section>]
    if [[ $line = \[* ]]; then
        line=${line//\[/}
        line=${line//\]/}

        if [ "$line" = "global" ]; then
            _SERVICE="$line"
            continue
        elif [ "$_SERVICE" = "global" ]; then
            # this is the 1st service in file
            setup_global
            _SERVICE="$line"
            continue
        else
            action $_SERVICE

            # prepare for this service
            _SERVICE="$line"

            # reset known variables
            mkdirs=
            tarfile=
            rpms=
            include=

            continue
        fi
    else
        line=${line/\ =\ /=}
        eval "$line"
    fi

done

sed -i 's/daemon off;/#daemon off;/' $install_root/nginx/conf/nginx.conf
sed -i '/^CMService.HttpHost =/cCMService.HttpHost = 0.0.0.0' $install_root/cmservice/conf/cmservice.properties
sed -i '/^LogClustering.HttpHost =/cLogClustering.HttpHost = 0.0.0.0' $install_root/log-analysis/config/log.analysis.properties
sed -i '/^HttpHost =/cHttpHost = 0.0.0.0' $install_root/chartservice/conf/chartservice.properties
sed -i '/^current_node_name =/ccurrent_node_name = alertd' $install_root/alertd/conf/cloudmon.alerting.conf
sed -i '/^http_server_host =/chttp_server_host = alertd' $install_root/alertd/conf/cloudmon.alerting.conf
sed -i '/^network.host:/cnetwork.host: elasticsearch' $install_root/elasticsearch/config/elasticsearch.yml
sed -i '/^path.data:/c#path.data:' $install_root/elasticsearch/config/elasticsearch.yml
sed -i 's/\/opt\/mysql\/bin\/mysql/mysql/g' $install_root/umanager/bin/get_tokens.sh
sed -i "/^var server =/cvar server = 'http:\/\/chartservice:5012\/chart';"  $install_root/alertd/conf/reporting/load.js
sed -i '/^tmpFolder=/ctmpFolder=\/opt\/report_tmp' $install_root/alertd/conf/cloudmon.alerting.conf
sed -i 's/asynchbase-1.7.2.jar/asynchbase-1.8.2.jar/' $install_root/opentsdb/bin/start.sh
bash $install_root/agent/bin/repackage.sh
chown -R 101:101 $install_root/nginx/

exit 0
