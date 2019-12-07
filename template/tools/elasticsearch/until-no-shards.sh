#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

while true; do
    SHARD_COUNT=$($CURL $ES_URL/_cat/shards?pretty | grep "<:host_ip:>" | wc -l)
    if [ "$SHARD_COUNT" -eq "0" ]; then
        break
    fi
    echo "SHARD_COUNT = $SHARD_COUNT"
    sleep 5
done

echo "SHARD_COUNT is now 0"

exit 0
