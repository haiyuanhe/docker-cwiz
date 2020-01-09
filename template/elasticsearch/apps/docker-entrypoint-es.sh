#!/bin/bash

TS_PASS=${TS_PASS:-'Cwiz_123'}
KS_PASS=${KS_PASS:-'Cwiz_123'}
CLUSTER_NAME=${CLUSTER_NAME:-'cloudwiz'}

install_plugins() {
    if [[ -d /plugins ]]; then
        for plugin in `ls /plugins`; do
            grep "$plugin" /install_plugins
            if [[ $? -ne 0 ]]; then
                elasticsearch-plugin install -b -v file:///plugins/$plugin
                if [[ $? -eq 0 ]]; then
                    echo "$plugin" >> /install_plugins
                fi
            fi
        done
    fi
}

# If use extra-config-file do this.
CONFIG="/usr/share/elasticsearch/config/elasticsearch.yml"
if [[ -f /config/elasticsearch.yml ]]; then
    cp -pr "/config/elasticsearch.yml" "$CONFIG"
fi
echo "" >> "$CONFIG"

(
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

    # Read in env as a new-line separated array. This handles the case of env variables have spaces and/or carriage returns. See #313
    IFS=$'\n'
    for VAR in $(env)
    do
        env_var=$(echo "$VAR" | cut -d= -f1)
        # if [[ "$EXCLUSIONS" = *"|$env_var|"* ]]; then
        #     echo "Excluding $env_var from es config"
        #     continue
        # fi

        if [[ $env_var =~ ^SSL_ ]]; then
            p_name=$(echo "$env_var" | cut -d_ -f2- | tr '[:upper:]' '[:lower:]' | tr _ .)
            updateConfig "$p_name" "${!env_var}" "$CONFIG"
        fi
    done
)

if [[ -d /plugins ]]; then
    if [[ ! -f /install_plugins ]]; then
        touch /install_plugins
    fi
    install_plugins
fi

# exec /docker-entrypoint.sh elasticsearch
/docker-entrypoint.sh elasticsearch &

# init ssl
sleep 30
cd /usr/share/elasticsearch/plugins/search-guard-5/tools
chmod a+x sgadmin.sh
while [[ 1 ]]; do
    echo "Wait for elasticsearch ready..."
    ./sgadmin.sh -ts ../../../config/truststore.jks -tspass $TS_PASS \
      -ks ../../../config/sgadmin.jks -kspass $KS_PASS -cn $CLUSTER_NAME \
      -nhnv -cd ../sgconfig/ -h `hostname -f`
    if [[ $? -eq 0 ]]; then  
        echo "elasticsearch is ready."
        break
    fi
    sleep 3
done

# docker can has multi backend-processes,but must keep a process in webfront, Keep it running in webfront
while [[ 1 ]]; do
    sleep 60
done
