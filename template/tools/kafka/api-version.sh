#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

$KAFKA_HOME/bin/kafka-broker-api-versions.sh --bootstrap-server $KAFKA_HOST

echo
exit 0
