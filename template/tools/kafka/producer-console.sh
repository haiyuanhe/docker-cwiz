#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

$KAFKA_HOME/bin/kafka-console-producer.sh --broker-list <:host_ip:>:9092 --topic $1

exit 0
