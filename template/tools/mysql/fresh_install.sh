#!/bin/bash

. <:install_root:>/tools/crypt/utils.sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<:install_root:>/mysql/lib

MYSQL_HOME=<:install_root:>/mysql
DATA_DIR=<:data_root:>/mysql
INIT_FILE=<:install_root:>/tools/mysql/create_user.sql
TEMP_FILE=`mktemp /tmp/tmp.XXXXXXXXXXXXXXXX`

mkdir -p $DATA_DIR
chmod 750 $DATA_DIR

decrypt_MySQLPass

_password=$decrypt_pass

cp $INIT_FILE $TEMP_FILE
sed -i "s/PASSWORD/$_password/g" $TEMP_FILE

_password=
unset decrypt_pass

$MYSQL_HOME/bin/mysqld --no-defaults --initialize-insecure --basedir=$MYSQL_HOME --datadir=$DATA_DIR --init-file=$TEMP_FILE --explicit_defaults_for_timestamp
rm -f $TEMP_FILE

$MYSQL_HOME/bin/mysql_ssl_rsa_setup --basedir=$MYSQL_HOME --datadir=$DATA_DIR

exit 0
