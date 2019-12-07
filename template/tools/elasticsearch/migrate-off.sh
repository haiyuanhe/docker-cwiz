#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

one_required_arg "<node-ip>"

$CURL -XPUT "$ES_URL/_cluster/settings" -H 'Content-Type: application/json' -d "{\"transient\":{\"cluster.routing.allocation.exclude._ip\":\"$1\",\"cluster.routing.allocation.exclude._host\":\"$1\"}}"
