#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/utils.sh

while [ 1 ]
do
    check_url "$1"

    if [ $? -eq 0 ]; then
        echo
        echo "Service is available"
        break
    else
        sleep 5
        printf '.'
    fi
done
