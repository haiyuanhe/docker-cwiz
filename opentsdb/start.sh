#!/bin/bash

KERBEROS_REALM=${KERBEROS_REALM:-'CWIZ.COM'}
KERBEROS_HABSE_CLIENT_PRIMARY=${KERBEROS_HABSE_CLIENT_PRIMARY:-'hbase'}
KERBEROS_ZOOKEEPER_CLIENT_PRIMARY=${KERBEROS_HABSE_CLIENT_PRIMARY:-'root'}
HBASE_ZK_QUORUM=${HBASE_ZK_QUORUM}

OPENTSDB_HOME="$INSTALL_ROOT/opentsdb"

# Enable sasl
echo "" >> "$OPENTSDB_HOME/conf/opentsdb.conf"

(
    function updateConfig() {
        key=$1
        value=$2
        file=$3

        # Omit $value here, in case there is sensitive information
        echo "[Configuring] '$key' in '$file'"

        # If config exists in file, replace it. Otherwise, append to file.
        if grep -E -q "^#?$key=" "$file"; then
            sed -r -i "s@^#?$key=.*@$key=$value@g" "$file" #note that no config values may contain an '@' char
        else
            echo "$key=$value" >> "$file"
        fi
    }

    if [[ ! -z "$HBASE_ZK_QUORUM" ]]; then
        updateConfig "tsd.storage.hbase.zk_quorum" "${HBASE_ZK_QUORUM}" "$OPENTSDB_HOME/conf/opentsdb.conf"
    fi
    updateConfig "hbase.security.auth.enable" "true" "$OPENTSDB_HOME/conf/opentsdb.conf"
    updateConfig "hbase.security.authentication" "kerberos" "$OPENTSDB_HOME/conf/opentsdb.conf"
    updateConfig "hbase.kerberos.regionserver.principal" "${KERBEROS_HABSE_CLIENT_PRIMARY}/_HOST@${KERBEROS_REALM}" "$OPENTSDB_HOME/conf/opentsdb.conf"
    updateConfig "hbase.sasl.clientconfig" "HBaseClient" "$OPENTSDB_HOME/conf/opentsdb.conf"
    sed -i '/^export JVMFLAGS="-Djava.security.auth.login.config=.*\/jaas.conf/d' $OPENTSDB_HOME/bin/start.sh
    sed -i 's/enablesystemassertions $JVMFLAGS/enablesystemassertions/' $OPENTSDB_HOME/bin/start.sh
    sed -i '/^OPENTSDB_HOME=/a\export JVMFLAGS="-Djava.security.auth.login.config=$OPENTSDB_HOME/conf/jaas.conf"' $OPENTSDB_HOME/bin/start.sh
    sed -i 's/enablesystemassertions/& $JVMFLAGS/' $OPENTSDB_HOME/bin/start.sh
}

cat > "$OPENTSDB_HOME/conf/jaas.conf" << EOF
HBaseClient {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    storeKey=true
    keyTab="/kerberos/hbase.keytab"
    principal="${KERBEROS_HABSE_CLIENT_PRIMARY}/`hostname -f`@${KERBEROS_REALM}";
};
Client {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=true
    storeKey=true
    keyTab="/kerberos/centos.keytab"
    principal="${KERBEROS_ZOOKEEPER_CLIENT_PRIMARY}/`hostname -f`@${KERBEROS_REALM}";
};
EOF

# make sure HMaster is ready
echo "Waiting for HMaster to get ready"
NAME=hbase-master
PORT=16010
_hmaster_hosts=( $NAMaE )
_ready=0
while [ 1 ]
do
    _done=0
    _hmaster_url="http://hbase-master:16010/master-status?format=json"
    _status=$(curl -s "$_hmaster_url")

    if [ "_${_status//[[:space:]]/}_" = "_[]_" ]; then
        _done=1
    fi
    echo "status: $_status"
    echo "done: $_done"
    echo "_ready: $_ready"

    if [ $_done -ne 0 ]; then
        _ready=$((_ready+1))
        echo "HMaster is getting ready"
        sleep 2
    else
        _ready=0
        echo "HMaster is not ready"
        sleep 10
    fi

    if [ $_ready -gt 8 ]; then
        echo "HMaster is ready"
        sleep 10
        break
    fi
done

while true;do
    _status=$(curl -I -m 10 -o /dev/null -s -w %{http_code}  http://hbase-master:16010/table.jsp?name=vsms_callbackInfo)
    if [[ $_status -eq 200 ]];then
        echo "hbase-table is ready ..."
        echo "staring opentsdb ..."
        sleep 5
        break
    else
        echo "waiting for hbase-tables ..."
        sleep 2
    fi
done

${INSTALL_ROOT}/opentsdb/bin/start.sh
