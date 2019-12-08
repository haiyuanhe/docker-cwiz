#!/bin/bash

. <:install_root:>/startup/envs.sh

function kill_child_process {
    CHILD_PID=$(pgrep -P $$)
    kill $CHILD_PID
}

trap kill_child_process EXIT

_JAR=$(one_cloudwiz_jar <:install_root:>/oneagent/bin)


<:java_home:>/bin/java -Dlog4j.configuration=<:install_root:>/oneagent/conf/log4j.yml -jar $_JAR com.cloudwiz.oneagent.OneagentApplication --spring.config.location=<:install_root:>/oneagent/conf/application.yml

