#!/bin/bash

. <:install_root:>/tools/crypt/utils.sh

if [ -d "<:install_root:>/mysql" ]; then
    MYSQL_CLIENT="<:install_root:>/mysql/bin/mysql"
else
    MYSQL_CLIENT="mysql"
fi

decrypt_MySQLPass

_password=$decrypt_pass

for sql in <:install_root:>/tools/mysql/sql/*.sql; do
    $MYSQL_CLIENT --host <:mysql_master_ip:> --port <:mysql_port:> -u <:mysql_username:> -p$_password --silent < $sql > /dev/null 2>&1
done

$MYSQL_CLIENT --host <:mysql_master_ip:> --port <:mysql_port:> -u <:mysql_username:> -p$_password --silent <:grafana_database:> < <:install_root:>/webfront/data/sql/cwiz_static.sql > /dev/null 2>&1

_password=
unset decrypt_pass

<:install_root:>/tools/certs/create-mysql-ssl.sh

exit 0
