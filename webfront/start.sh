#!/bin/bash

while true;do
    curl mysql-server:3306
    if [[ $? -eq 0 ]];then
        break
    fi
    echo "wait for mysql ..."
    sleep 2
done
echo "starting webfront ..."
/opt/webfront/bin/grafana-server -homepath=/opt/webfront
