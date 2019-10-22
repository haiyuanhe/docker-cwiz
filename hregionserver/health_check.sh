#!/bin/bash

_status=$(curl -s "http://hbase-master:16010/master-status?format=json")

if [ "_${_status//[[:space:]]/}_" = "_[]_" ]; then
    _tables=$(echo list | /opt/hbase-1.4.10/bin/hbase shell)
    echo $_tables | grep tsdb-uid
    if [[ $? -eq 0 ]]; then
        exit 0
    else
        exit 1       
    fi
else
    exit 1
fi


