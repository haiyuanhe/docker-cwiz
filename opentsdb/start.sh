#!/bin/bash

# make sure HMaster is ready
echo "Waiting for HMaster to get ready"
NAME=hbase-master
PORT=16010
_hmaster_hosts=( $NAMaE )
_ready=0
while [ 1 ]
do
    _done=0
    _hmaster_url="http://hbase-master:16010/master-status?format=json"
    _status=$(curl -s "$_hmaster_url")

    if [ "_${_status//[[:space:]]/}_" = "_[]_" ]; then
        _done=1
    fi
    echo "status: $_status"
    echo "done: $_done"
    echo "_ready: $_ready"

    if [ $_done -ne 0 ]; then
        _ready=$((_ready+1))
        echo "HMaster is getting ready"
        sleep 2
    else
        _ready=0
        echo "HMaster is not ready"
        sleep 10
    fi

    if [ $_ready -gt 8 ]; then
        echo "HMaster is ready"
        sleep 10
        break
    fi
done

while true;do
    _status=$(curl -I -m 10 -o /dev/null -s -w %{http_code}  http://hbase-master:16010/table.jsp?name=vsms_callbackInfo)
    if [[ $_status -eq 200 ]];then
        echo "hbase-table is ready ..."
        echo "staring opentsdb ..."
        sleep 5
        break
    else
        echo "waiting for hbase-tables ..."
        sleep 2
    fi
done

/opt/opentsdb/bin/start.sh
