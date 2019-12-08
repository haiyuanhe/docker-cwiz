#!/bin/bash

OPENTSDB_URL=http://localhost:4242
LOG_FILE=<:log_root:>/start_services.log

STATUS="DEAD"

for i in 1 2 3 4 5
do
    _status=$(curl -s -o /dev/null -m 30 -w "%{http_code}" "$OPENTSDB_URL")

    if [ "$_status" -lt "300" ] && [ "$_status" -ge "200" ]; then
        STATUS="OK"
        break
    else
        sleep 5
    fi
done

TS=$(date)

if [ "$STATUS" = "DEAD" ]; then
    echo "$TS Restarting OpenTSDB..." >> $LOG_FILE
    PID=$(pgrep -f opentsdb.conf)
    kill $PID
    sleep 5
    kill -9 $PID
else
    echo "$TS OpenTSDB is doing just fine!" >> $LOG_FILE
fi

exit 0
