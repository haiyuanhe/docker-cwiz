#!/bin/bash

# if supervisorctl is not on PATH, add it
hash supervisorctl 2>/dev/null
if [ "$?" -ne 0 ]; then
    export PATH=$PATH:<:install_root:>/supervisord/altenv/bin
fi

# start supervisord and all the services in order. Used during machine
# restart

startup_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $startup_dir/helpers.sh

array=( "nginx" "zookeeper" "namenode" "datanode" "master" "regionserver" "mysql" "cmservice" "elasticsearch" )
for serv_name in "${array[@]}"
do
   check_and_launch_service ${serv_name}
   sleep 10
done

# We must be sure that hbase is completely ready before launch opentsdb.
wait_for_hbase_ready
echo "Hbase is ready"
sleep 30 

array=( "kafka" "opentsdb" "alertd" "log-analysis" "log-processor" "webfront" "umanager" )
for serv_name in "${array[@]}"
do
   check_and_launch_service ${serv_name}
   sleep 2
done

exit 0
