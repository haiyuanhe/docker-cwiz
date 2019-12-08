#!/bin/bash

# start supervisord and all the services in order. Used during machine
# restart

startup_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $startup_dir/helpers.sh

array=( <:all_services:> )
for serv_name in "${array[@]}"
do
   check_and_launch_service ${serv_name}
   sleep 10
done

exit 0
