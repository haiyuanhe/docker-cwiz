#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

known=('health' 'state' 'stats')

if [ $# -lt 1 ]; then
    $CURL $ES_URL/_cluster/health?pretty
elif [[ " ${known[*]} " == *" $1 "* ]]; then
    $CURL $ES_URL/_cluster/$1?pretty
else
    echo "Unknown cluster info category: $1"
    echo "Accepted info categories: ${known[@]}"
fi

exit 0
