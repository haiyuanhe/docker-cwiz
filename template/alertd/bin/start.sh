#!/bin/bash

. <:install_root:>/startup/envs.sh

function kill_child_process {
    CHILD_PID=$(pgrep -P $$)
    kill $CHILD_PID
}

trap kill_child_process EXIT


export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<:install_root:>/chart-rpms/usr/lib64
export FONTCONFIG_PATH=$FONTCONFIG_PATH:<:install_root:>/chart-rpms/etc/fonts

_JAR=$(one_cloudwiz_jar <:install_root:>/alertd/bin)

<:java_home:>/bin/java -Xms$ALERTD_HEAP_SIZE_MIN -Xmx$ALERTD_HEAP_SIZE_MAX -XX:OnOutOfMemoryError="kill -9 %p" -Xloggc:<:log_root:>/alertd/alertd-%t.gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCCause -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=2M -cp <:install_root:>/alertd/conf:$_JAR -DHBASE_CONF_DIR=<:install_root:>/alertd/conf/hbase_configs/ -DHDFS_CONF_DIR=<:install_root:>/alertd/conf/hdfs_configs/ -Dlog4j.configuration=alertd-log4j.properties -javaagent:<:install_root:>/alertd/bin/jolokia-jvm-1.3.6-agent.jar=host=0.0.0.0,port=7001,maxCollectionSize=0 com.cloudwiz.daemon.AlertService
