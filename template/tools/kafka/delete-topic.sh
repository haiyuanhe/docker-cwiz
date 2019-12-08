#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

$KAFKA_HOME/bin/kafka-topics.sh --delete --zookeeper $ZK_HOST --topic $1

exit 0
