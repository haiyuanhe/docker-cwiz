#!/bin/bash

#set -e

. <:install_root:>/tools/crypt/utils.sh
decrypt_SSLPass
if [ "abc$1" = "abc" ]; then
    STOREPASS=${ssl_decrypt_pass}
else
    STOREPASS=$1
fi

WORK_HOME=$(cd `dirname $0`; pwd)
CERT_ROOT=<:install_root:>/certs/elasticsearch
ES_NODES=( <:es_nodes:> )

# clean old certs
./clean.sh

# CA and Truststtore password
echo "CA password: $STOREPASS" >> $CERT_ROOT/Readme.txt
echo "Truststore password: $STOREPASS" >> $CERT_ROOT/Readme.txt
$WORK_HOME/gen_root_ca.sh "$STOREPASS" "$STOREPASS"

for node in ${ES_NODES[@]}
do
  # ./gen_node_cert.sh centos111 `rand | cut -c1-20` $CA_PASS
  $WORK_HOME/gen_node_cert.sh "$node" "$STOREPASS" "$STOREPASS"
done

# # generate client certs
# # ./gen_client_node_cert.sh cwiz "$STOREPASS" "$STOREPASS"
$WORK_HOME/gen_client_node_cert.sh sgadmin "$STOREPASS" "$STOREPASS"

# update config: elasticsearch.yml
function updateConfig() {
    key=$1
    value=$2
    file=$3

    # Omit $value here, in case there is sensitive information
    echo "[Configuring] '$key' in '$file'"

    # If config exists in file, replace it. Otherwise, append to file.
    if grep -E -q "^#?$key:" "$file"; then
        sed -r -i "s@^#?$key:.*@$key: $value@g" "$file" #note that no config values may contain an '@' char
    else
        echo "$key: $value" >> "$file"
    fi
}
CONFIG=<:install_root:>/elasticsearch/config/elasticsearch.yml
updateConfig "searchguard.ssl.transport.keystore_password" "$STOREPASS" "$CONFIG"
updateConfig "searchguard.ssl.transport.truststore_password" "$STOREPASS" "$CONFIG"
updateConfig "searchguard.ssl.http.keystore_password" "$STOREPASS" "$CONFIG"
updateConfig "searchguard.ssl.http.truststore_password" "$STOREPASS" "$CONFIG"
