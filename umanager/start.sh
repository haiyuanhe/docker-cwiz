#!/bin/bash

while true;do
    curl mysql-server:3306
    if [[ $? -eq 0 ]];then
        break
    fi
    echo "wait for mysql ..."
    sleep 2
done
sleep 2
if [ ! -d "${INSTALL_ROOT}/umanager/.gnupg" ];then
    echo "gen keys ..."
    ${INSTALL_ROOT}/umanager/bin/gen_keys.py cloudwiz service@cloudwiz.cn
else
    echo "keys already exists, skip genkeys ..."
fi

${INSTALL_ROOT}/umanager/bin/um_daemon.py
