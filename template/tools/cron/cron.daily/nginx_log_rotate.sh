#!/bin/bash

LOG_DIRS=("<:log_root:>/nginx" "<:install_root:>/nginx/logs")
PID_FILE="<:install_root:>/nginx/logs/nginx.pid"

for dir in ${LOG_DIRS[@]}
do
    rm -f ${dir}/access.log.*
    mv ${dir}/access.log ${dir}/access.log.0

    rm -f ${dir}/error.log.*
    mv ${dir}/error.log ${dir}/error.log.0
done

kill -USR1 `cat $PID_FILE`

exit 0
