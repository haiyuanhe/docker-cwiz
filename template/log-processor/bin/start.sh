#!/bin/bash

. <:install_root:>/startup/envs.sh

export JAVA_HOME=<:java_home:>

_JAR=$(one_cloudwiz_jar <:install_root:>/log-processor/bin)

<:java_home:>/bin/java -Xms$LOG_PROCESSOR_HEAP_SIZE_MIN -Xmx$LOG_PROCESSOR_HEAP_SIZE_MAX -XX:OnOutOfMemoryError="kill -9 %p" -cp $_JAR -Dorg.jboss.netty.epollBugWorkaround=true -Dlog4j.configuration=file:<:install_root:>/log-processor/config/log4j.properties com.cloudwiz.log.processor.Main --config <:install_root:>/log-processor/config/log.processor.properties --patterns <:install_root:>/log-processor/config/patterns/grok-patterns
