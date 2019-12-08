#!/bin/bash

. <:install_root:>/startup/envs.sh

function kill_child_process {
    CHILD_PID=$(pgrep -P $$)
    kill $CHILD_PID
}

trap kill_child_process EXIT

_JAR=$(one_cloudwiz_jar <:install_root:>/metric-proxy/bin)

<:java_home:>/bin/java -Xms$METRIC_PROXY_HEAP_SIZE_MIN -Xmx$METRIC_PROXY_HEAP_SIZE_MAX -XX:OnOutOfMemoryError="kill -9 %p" -Dlog4j.configuration=file:<:install_root:>/metric-proxy/config/log4j.properties -jar $_JAR com.cloudwiz.metricproxy.Main --spring.profiles.active=dev --spring.config.location=<:install_root:>/metric-proxy/config/application.yml
