#!/bin/bash

export LD_LIBRARY_PATH=<:install_root:>/mysql/lib:$LD_LIBRARY_PATH

#sleep 20 && <:install_root:>/tools/mysql/update_data_sources.sh &

if [ "$1" = "master" ]; then
    <:install_root:>/mysql/bin/mysqld_safe --defaults-file=<:install_root:>/mysql/my-master.cnf --explicit_defaults_for_timestamp
else
    <:install_root:>/mysql/bin/mysqld_safe --defaults-file=<:install_root:>/mysql/my-slave.cnf --explicit_defaults_for_timestamp
fi

exit 0
