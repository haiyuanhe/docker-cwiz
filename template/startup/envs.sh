#!/bin/bash


if [ -r "<:install_root:>/startup/all_hosts.sh" ]; then
    . <:install_root:>/startup/all_hosts.sh
fi


# get total memory in MB
HOST_MEMORY=$(free -m -t|grep Mem:|awk '{print $2}')

# alertd memory size
let "_TEMP = $HOST_MEMORY / 16"
ALERTD_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 8"
ALERTD_HEAP_SIZE_MAX=${_TEMP}m


# chartservice memory size
let "_TEMP = $HOST_MEMORY / 256"
CHARTSVC_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 128"
CHARTSVC_HEAP_SIZE_MAX=${_TEMP}m


# cmservice memory size
let "_TEMP = $HOST_MEMORY / 128"
CMSERVICE_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 64"
CMSERVICE_HEAP_SIZE_MAX=${_TEMP}m


# elasticsearch memory size
let "_TEMP = $HOST_MEMORY / 16"
ELASTICSEARCH_HEAP_SIZE_MIN=${_TEMP}m
ELASTICSEARCH_HEAP_SIZE_MAX=${_TEMP}m


# hadoop memory size
let "_TEMP = $HOST_MEMORY / 32"
HADOOP_HEAP_SIZE_MIN=${_TEMP}m
HADOOP_HEAP_SIZE_MAX=${_TEMP}m


# hbase memory size
let "_TEMP = $HOST_MEMORY / 4"
HBASE_HEAP_SIZE_MIN=${_TEMP}m
HBASE_HEAP_SIZE_MAX=${_TEMP}m


# kafka memory size
let "_TEMP = $HOST_MEMORY / 64"
KAFKA_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 32"
KAFKA_HEAP_SIZE_MAX=${_TEMP}m


# log-analysis memory size
let "_TEMP = $HOST_MEMORY / 128"
LOG_ANALYSIS_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 64"
LOG_ANALYSIS_HEAP_SIZE_MAX=${_TEMP}m


# log-pp memory size
let "_TEMP = $HOST_MEMORY / 128"
LOG_PP_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 128"
LOG_PP_HEAP_SIZE_MAX=${_TEMP}m


# log-processor memory size
let "_TEMP = $HOST_MEMORY / 128"
LOG_PROCESSOR_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 64"
LOG_PROCESSOR_HEAP_SIZE_MAX=${_TEMP}m


# metric-proxy memory size
let "_TEMP = $HOST_MEMORY / 128"
METRIC_PROXY_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 64"
METRIC_PROXY_HEAP_SIZE_MAX=${_TEMP}m


# opentsdb memory size
let "_TEMP = $HOST_MEMORY / 32"
OPENTSDB_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 16"
OPENTSDB_HEAP_SIZE_MAX=${_TEMP}m


# permission memory size
# Note: the calculated sizes may be too small
let "_TEMP = $HOST_MEMORY / 512"
PERMISSION_HEAP_SIZE_MIN=32m
let "_TEMP = $HOST_MEMORY / 256"
PERMISSION_HEAP_SIZE_MAX=64m

# cloudwiz-user memory size
let "_TEMP = $HOST_MEMORY / 64"
CLOUDWIZ_USER_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 32"
CLOUDWIZ_USER_HEAP_SIZE_MAX=${_TEMP}m

# zookeeper memory size
let "_TEMP = $HOST_MEMORY / 256"
ZOOKEEPER_HEAP_SIZE_MIN=${_TEMP}m
let "_TEMP = $HOST_MEMORY / 128"
ZOOKEEPER_HEAP_SIZE_MAX=${_TEMP}m


function one_cloudwiz_jar()
{
    local folder=$1
    if [ -f $folder/cloudwiz-*.jar ];then
        local jar=$(ls $folder/cloudwiz-*.jar | head -n 1)
    elif [ -f $folder/oneagent-*.jar ];then
        local jar=$(ls $folder/oneagent-*.jar | head -n 1)
    fi
    if [ -z "$jar" ]; then
        echo "[ERROR] Unable to find cloudwiz-*.jar under $folder"
    fi

    echo $jar
}
