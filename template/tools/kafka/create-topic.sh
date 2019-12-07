#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

$KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $ZK_HOST --replication-factor 1 --partitions 3 --topic $1

echo
exit 0
