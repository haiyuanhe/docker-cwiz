#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

known=('hot_threads' 'http' 'jvm' 'os' 'plugins' 'process' 'settings' 'stats' 'thread_pool' 'transport')

if [ $# -lt 1 ]; then
    $CURL $ES_URL/_nodes?pretty
elif [[ " ${known[*]} " == *" $1 "* ]]; then
    if [ $# -gt 1 ]; then
        $CURL $ES_URL/_nodes/$2/$1?pretty
    else
        $CURL $ES_URL/_nodes/$1?pretty
    fi
else
    echo "Unknown node info category: $1"
    echo "Accepted info categories: ${known[@]}"
fi

exit 0
