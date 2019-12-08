#!/bin/bash

. <:install_root:>/startup/envs.sh

let "total = 0"


echo "alertd: $ALERTD_HEAP_SIZE_MAX"
let "total += ${ALERTD_HEAP_SIZE_MAX/m/}"

echo "cmservice: $CMSERVICE_HEAP_SIZE_MAX"
let "total += ${CMSERVICE_HEAP_SIZE_MAX/m/}"

echo "elasticsearch: $ELASTICSEARCH_HEAP_SIZE_MAX"
let "total += ${ELASTICSEARCH_HEAP_SIZE_MAX/m/}"

echo "hadoop: $HADOOP_HEAP_SIZE_MAX"
let "total += ${HADOOP_HEAP_SIZE_MAX/m/}"

echo "hbase: $HBASE_HEAP_SIZE_MAX"
let "total += ${HBASE_HEAP_SIZE_MAX/m/}"

echo "kafka: $KAFKA_HEAP_SIZE_MAX"
let "total += ${KAFKA_HEAP_SIZE_MAX/m/}"

echo "log-clustering: $LOG_ANALYSIS_HEAP_SIZE_MAX"
let "total += ${LOG_ANALYSIS_HEAP_SIZE_MAX/m/}"

echo "log-processor: $LOG_PROCESSOR_HEAP_SIZE_MAX"
let "total += ${LOG_PROCESSOR_HEAP_SIZE_MAX/m/}"

echo "opentsdb: $OPENTSDB_HEAP_SIZE_MAX"
let "total += ${OPENTSDB_HEAP_SIZE_MAX/m/}"

echo "zookeeper: $ZOOKEEPER_HEAP_SIZE_MAX"
let "total += ${ZOOKEEPER_HEAP_SIZE_MAX/m/}"


echo "total: ${total}m"
let "total /= 1024"
echo "total: ${total}g"
