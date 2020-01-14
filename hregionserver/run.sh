#!/bin/bash

set -m

KERBEROS_REALM=${KERBEROS_REALM:-'CWIZ.COM'}
KERBEROS_HBASE_CLIENT_PRIMARY=${KERBEROS_HBASE_CLIENT_PRIMARY:-'hbase'}

${INSTALL_ROOT}/hbase-$HBASE_VERSION/bin/hbase regionserver start &
# Kerberos auth
kinit -kt /kerberos/${KERBEROS_HBASE_CLIENT_PRIMARY}.keytab ${KERBEROS_HBASE_CLIENT_PRIMARY}/`hostname -f`@${KERBEROS_REALM}
sleep 1
kinit -R
/create_table.sh
fg
