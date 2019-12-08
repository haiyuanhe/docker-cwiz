#!/bin/bash

. <:install_root:>/startup/envs.sh

function kill_child_process {
    CHILD_PID=$(pgrep -P $$)
    kill $CHILD_PID
}

trap kill_child_process EXIT

_JAR=$(one_cloudwiz_jar <:install_root:>/cmservice/bin)

<:java_home:>/bin/java -Xms$CMSERVICE_HEAP_SIZE_MIN -Xmx$CMSERVICE_HEAP_SIZE_MAX -Xloggc:<:log_root:>/cmservice/cmservice-%t.gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCCause -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=2M -cp <:install_root:>/cmservice/conf:$_JAR -Dlog4j.configuration=log4j.properties com.cloudwiz.cmservice.Main -c <:install_root:>/cmservice/conf/cmservice.properties
