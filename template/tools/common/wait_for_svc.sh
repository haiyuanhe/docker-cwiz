#!/bin/bash

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#. $DIR/utils.sh

_STATUS="RUNNING"

if [ $# -gt 1 ]; then
    _STATUS="$2"
fi

while [ 1 ]
do
    _stat=$(<:install_root:>/supervisord/altenv/bin/supervisorctl status | grep $1 | awk '{print $2}')

    if [ "$_stat" = "$_STATUS" ]; then
        echo
        echo "Service is available"
        break
    else
        sleep 5
        printf '.'
    fi
done
