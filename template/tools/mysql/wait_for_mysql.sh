#!/bin/bash

. <:install_root:>/tools/crypt/utils.sh

if [ -f "<:install_root:>/mysql/bin/mysqladmin" ]; then
    MYSQL_ADMIN="<:install_root:>/mysql/bin/mysqladmin"
else
    MYSQL_ADMIN="mysqladmin"
fi

decrypt_MySQLPass

_password=$decrypt_pass

while [ 1 ]
do
    $MYSQL_ADMIN -u root -p$_password --socket=<:install_root:>/mysql/mysql.sock status > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo
        echo "MySQL is running"
        sleep 5
        break
    else
        sleep 5
        printf '.'
    fi
done

_password=
unset decrypt_pass

exit 0
