#!/bin/bash

<:install_root:>/hadoop/bin/hadoop dfs -rmr /hbase/data/default/*/*.tmp >/dev/null 2>&1
<:install_root:>/hadoop/bin/hadoop dfs -rmr /hbase/oldWALs/* >/dev/null 2>&1
rm -f /var/log/alertd-20* > /dev/null 2>&1
rm -f /var/log/alertd.log.* > /dev/null 2>&1
rm -f /var/log/cmservice.log.* > /dev/null 2>&1
rm -f /tmp/reporting.2.* > /dev/null 2>&1
exit 0