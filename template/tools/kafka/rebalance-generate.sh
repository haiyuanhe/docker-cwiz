#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

$KAFKA_HOME/bin/kafka-reassign-partitions.sh --zookeeper $ZK_HOST --generate --broker-list "0,1" --topics-to-move-json-file topics-to-move.json

echo
exit 0
