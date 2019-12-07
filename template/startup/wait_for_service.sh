#!/bin/bash

echo "Waiting for service $1 to start"

started=false

while [ $started == false ]
do
    stats=$(./supervisord/altenv/bin/supervisorctl status $1)
    if [[ $stats == *RUNNING* ]]; then
        echo
        echo "Service $1 is running"
        break
    else
        sleep 5
        printf '.'
    fi
done

exit 0
