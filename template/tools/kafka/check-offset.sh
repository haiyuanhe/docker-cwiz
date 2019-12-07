#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

$KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server <:host_ip:>:<:kafka_port:> --group log-processor-es --describe
$KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server <:host_ip:>:<:kafka_port:> --group log-processor-tsd --describe
$KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server <:host_ip:>:<:kafka_port:> --group cloudwiz-kafka-metric --describe

echo
exit 0
