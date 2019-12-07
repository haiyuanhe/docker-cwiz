#!/bin/bash

. <:install_root:>/tools/crypt/utils.sh

# Setup replication only on our own MySQL installation.
if [ ! -d "<:install_root:>/mysql" ]; then
    exit 0
fi

MYSQL_CLIENT=<:install_root:>/mysql/bin/mysql
ENABLE_REPLICATION_SQL_FILE=<:install_root:>/tools/mysql/enable_replication.sql
TEMP_FILE=`mktemp /tmp/tmp.XXXXXXXXXXXXXXXX`

decrypt_MySQLPass

_password=$decrypt_pass

cp $ENABLE_REPLICATION_SQL_FILE $TEMP_FILE
sed -i "s/PASSWD/$_password/g" $TEMP_FILE

$MYSQL_CLIENT -u root -p$_password --silent --socket=<:install_root:>/mysql/mysql.sock < $TEMP_FILE > /dev/null 2>&1

_password=
unset decrypt_pass

rm -f $TEMP_FILE

exit 0
