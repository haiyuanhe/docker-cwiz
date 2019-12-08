#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

if [ $# -lt 1 ]; then
    _index=_all
elif [ $# -lt 2 ]; then
    _index=$1
fi

$CURL $ES_URL/$_index/_settings?pretty
