#!/bin/bash

. <:install_root:>/tools/crypt/utils.sh

decrypt_MySQLPass

PASSWORD=$decrypt_pass
USERNAME=<:mysql_username:>
FILENAME=<:install_root:>/umanager/config/tokens

TOKENS=$(<:install_root:>/mysql/bin/mysql --host <:nginx_ip:> --port 3308 -u $USERNAME -p$PASSWORD --batch --silent -e 'select a.`key` from <:grafana_database:>.systems s join <:grafana_database:>.api_key a on s.org_id = a.org_id and s.id = a.name where a.deleted = 0')

PASSWORD=
unset decrypt_pass

if [ $? -eq 0 ]; then
    rm -f ${FILENAME}.new
    for token in $TOKENS
    do
        echo $token >> ${FILENAME}.new
    done
fi

if [ -f $FILENAME ]; then
    OLDSIZE=$(wc -l ${FILENAME} | cut -d' ' -f1)
else
    OLDSIZE=0
fi

NEWSIZE=$(wc -l ${FILENAME}.new | cut -d' ' -f1)

if [ $NEWSIZE -gt $OLDSIZE ]; then
    mv -f ${FILENAME}.new ${FILENAME}
else
    echo "Nothing new"
fi

exit 0
