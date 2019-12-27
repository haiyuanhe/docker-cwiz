#!/bin/bash

. <:install_root:>/tools/crypt/utils.sh
decrypt_SSLPass
if [ "abc$1" = "abc" ]; then
    STOREPASS=${ssl_decrypt_pass}
else
    STOREPASS=$1
fi

# update config: server.properties
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
CONFIG=<:install_root:>/kafka/config/server.properties
updateConfig "ssl.keystore.password" "$STOREPASS" "$CONFIG"
updateConfig "ssl.key.password" "$STOREPASS" "$CONFIG"
updateConfig "ssl.truststore.password" "$STOREPASS" "$CONFIG"
