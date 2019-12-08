#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

if [ -f reassignment.json ]; then
    $KAFKA_HOME/bin/kafka-reassign-partitions.sh --zookeeper $ZK_HOST --execute --reassignment-json-file reassignment.json
else
    echo "Please run rebalance-generate.sh and save the bottom part of the output to 'reassignment.json', then run this command"
fi

exit 0
