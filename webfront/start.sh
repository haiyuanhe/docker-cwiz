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
${INSTALL_ROOT}/webfront/bin/grafana-server -homepath=${INSTALL_ROOT}/webfront
