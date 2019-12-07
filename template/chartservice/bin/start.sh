#!/bin/bash

. <:install_root:>/startup/envs.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<:install_root:>/chart-rpms/usr/lib64
export FONTCONFIG_PATH=$FONTCONFIG_PATH:<:install_root:>/chart-rpms/etc/fonts

_JAR=$(one_cloudwiz_jar <:install_root:>/chartservice/bin)

<:java_home:>/bin/java -Xms$CHARTSVC_HEAP_SIZE_MIN -Xmx$CHARTSVC_HEAP_SIZE_MAX -Xloggc:<:log_root:>/chartservice/chartservice-%t.gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCCause -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=2M -cp <:install_root:>/chartservice/conf:$_JAR -Dlog4j.configuration=log4j.properties com.cloudwiz.chartservice.ChartService
