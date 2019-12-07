#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

/usr/bin/curl -s -XPUT "http://$ES_URL/_cluster/settings" -H 'Content-Type: application/json' -d "{\"transient\":{\"cluster.routing.allocation.exclude._ip\":\"<:host_ip:>\",\"cluster.routing.allocation.exclude._host\":\"<:host_ip:>\"}}"
