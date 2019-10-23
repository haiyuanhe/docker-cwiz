#!/bin/bash

while true;do
    _status=$(curl -s "http://hbase-master:16010/master-status?format=json")
    if [ "_${_status//[[:space:]]/}_" = "_[]_" ]; then
        echo "hbase-master is ready ..."
        break
    else
        echo "wating for hbase-master ..."
        sleep 2
    fi
done

for i in {1..50};do
    echo "starting alertd ... $i"
    sleep 1
done
/opt/alertd/bin/start.sh
