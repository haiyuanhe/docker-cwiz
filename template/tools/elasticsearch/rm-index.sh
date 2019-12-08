#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

one_required_arg "<index>"

$CURL -XDELETE $ES_URL/$1/?pretty
