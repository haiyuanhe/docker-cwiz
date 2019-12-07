#!/bin/bash

TS=$(date +%s)

while [ $# -gt 1 ]; do
  PID=$(ps -ef | grep "$1" | grep -v "grep" | head -n 1 | awk '{print $2}')
  if [ "_${PID}_" != "__" ]; then
    CPU=$(top -b -n 1 -p $PID | grep "$PID" | awk '{print $9}')
    echo "${2}.cpu $TS $CPU"
  fi
  shift
  shift
done

exit 0
