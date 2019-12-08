#!/bin/bash

. <:install_root:>/startup/envs.sh

function kill_child_process {
    CHILD_PID=$(pgrep -P $$)
    kill $CHILD_PID
}

trap kill_child_process EXIT

_JAR=$(one_cloudwiz_jar <:install_root:>/permission/bin)

<:java_home:>/bin/java -Xms$PERMISSION_HEAP_SIZE_MIN -Xmx$PERMISSION_HEAP_SIZE_MAX -Dlogging.config=<:install_root:>/permission/config/log4j2.yml -jar $_JAR --spring.config.location=<:install_root:>/permission/config/application.yml

