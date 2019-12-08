#!/bin/bash

. <:install_root:>/startup/envs.sh

export JAVA_HOME=<:java_home:>

_JAR=$(one_cloudwiz_jar <:install_root:>/log-pp/bin)

<:java_home:>/bin/java -Xms$LOG_PP_HEAP_SIZE_MIN -Xmx$LOG_PP_HEAP_SIZE_MAX -XX:OnOutOfMemoryError="kill -9 %p" -cp $_JAR -Dorg.jboss.netty.epollBugWorkaround=true -Dlog4j.configuration=file:<:install_root:>/log-pp/config/log4j.properties com.cloudwiz.log.pp.Main --config <:install_root:>/log-pp/config/log.pp.properties
