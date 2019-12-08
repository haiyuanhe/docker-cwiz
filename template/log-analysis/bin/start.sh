#!/bin/bash

. <:install_root:>/startup/envs.sh

function kill_child_process {
    CHILD_PID=$(pgrep -P $$)
    kill $CHILD_PID
}

trap kill_child_process EXIT

_JAR=$(one_cloudwiz_jar <:install_root:>/log-analysis/bin)

<:java_home:>/bin/java -Xms$LOG_ANALYSIS_HEAP_SIZE_MIN -Xmx$LOG_ANALYSIS_HEAP_SIZE_MAX -XX:OnOutOfMemoryError="kill -9 %p" -cp $_JAR -Dlog4j.configuration=file:<:install_root:>/log-analysis/config/log4j.properties com.cloudwiz.log.analysis.Main -c <:install_root:>/log-analysis/config/log.analysis.properties
