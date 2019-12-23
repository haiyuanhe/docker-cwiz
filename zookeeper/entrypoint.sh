#!/bin/bash

set -e

KERBEROS_REALM=${KERBEROS_REALM:-'CWIZ.COM'}

# Allow the container to be started with `--user`
if [[ "$1" = 'zkServer.sh' && "$(id -u)" = '0' ]]; then
    chown -R zookeeper "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR" "$ZOO_LOG_DIR" "$ZOO_CONF_DIR" "$KEYTAB_DIR"
    exec gosu zookeeper "$0" "$@"
fi

# Generate the config only if it doesn't exist
if [[ ! -f "$ZOO_CONF_DIR/zoo.cfg" ]]; then
    CONFIG="$ZOO_CONF_DIR/zoo.cfg"

    echo "clientPort=2181" >> "$CONFIG"
    echo "dataDir=$ZOO_DATA_DIR" >> "$CONFIG"
    echo "dataLogDir=$ZOO_DATA_LOG_DIR" >> "$CONFIG"

    echo "tickTime=$ZOO_TICK_TIME" >> "$CONFIG"
    echo "initLimit=$ZOO_INIT_LIMIT" >> "$CONFIG"
    echo "syncLimit=$ZOO_SYNC_LIMIT" >> "$CONFIG"

    echo "autopurge.snapRetainCount=$ZOO_AUTOPURGE_SNAPRETAINCOUNT" >> "$CONFIG"
    echo "autopurge.purgeInterval=$ZOO_AUTOPURGE_PURGEINTERVAL" >> "$CONFIG"
    echo "maxClientCnxns=$ZOO_MAX_CLIENT_CNXNS" >> "$CONFIG"

    for server in $ZOO_SERVERS; do
        echo "$server" >> "$CONFIG"
    done

    # kerberos
    echo ""
    echo "quorum.auth.enableSasl=false" >> "$CONFIG"
    echo "kerberos.removeHostFromPrincipal=true" >> "$CONFIG"
    echo "kerberos.removeRealmFromPrincipal=true" >> "$CONFIG"
    echo "jaasLoginRenew=3600000" >> "$CONFIG"
    for server in $ZOO_SERVERS; do
        echo "authProvider.`echo ${server%%=*} | cut -d'.' -f2`=org.apache.zookeeper.server.auth.SASLAuthenticationProvider" >> "$CONFIG"
    done

cat > ${ZOO_CONF_DIR}/jaas.conf << EOF
Server {
  com.sun.security.auth.module.Krb5LoginModule required
  useKeyTab=true
  storeKey=true
  keyTab="/kerberos/zookeeper.keytab"
  principal="zookeeper/`hostname -f`@${KERBEROS_REALM}";
};
Client {
  com.sun.security.auth.module.Krb5LoginModule required
  useKeyTab=true
  storeKey=true
  keyTab="/kerberos/zookeeper.keytab"
  principal="zookeeper/`hostname -f`@${KERBEROS_REALM}";
};
EOF

cat > $ZOO_CONF_DIR/java.env << EOF
export JVMFLAGS="-Dsun.security.krb5.debug=false -Djava.security.auth.login.config=${ZOO_CONF_DIR}/jaas.conf"
EOF

fi

# Write myid only if it doesn't exist
if [[ ! -f "$ZOO_DATA_DIR/myid" ]]; then
    echo "${ZOO_MY_ID:-1}" > "$ZOO_DATA_DIR/myid"
fi

exec "$@"