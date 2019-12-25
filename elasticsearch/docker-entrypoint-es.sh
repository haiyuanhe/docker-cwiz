#!/bin/bash

TS_PASS=${TS_PASS:-'Cwiz_p0c'}
KS_PASS=${KS_PASS:-'Cwiz_p0c'}
CLUSTER_NAME=${CLUSTER_NAME:-'cloudwiz'}

install_plugins() {
    read -r -a plugins_list <<< "$(tr ',;' ' ' <<< "$ELASTICSEARCH_PLUGINS")"
    echo "Installing plugins: ${plugins_list[*]}"
    for plugin in "${plugins_list[@]}"; do
            grep "$plugin" /install_plugins
            if [[ $? -ne 0 ]]; then
                elasticsearch-plugin install -b -v "$plugin"
                # elasticsearch-plugin install -b -v "$plugin" >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    echo "$plugin" >> /install_plugins
                fi
            fi
    done
}

CONFIG="/usr/share/elasticsearch/config/elasticsearch.yml"

#Issue newline to config file in case there is not one already
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

if [[ ! -z "$ELASTICSEARCH_PLUGINS" ]]; then
    if [[ ! -f /install_plugins ]]; then
        touch /install_plugins
    fi
    install_plugins
fi

#exec /docker-entrypoint.sh elasticsearch
/docker-entrypoint.sh elasticsearch &

# init ssl
cd /usr/share/elasticsearch/plugins/search-guard-5/tools
sh ./sgadmin.sh -ts ../../../config/truststore.jks -tspass $TS_PASS \
   -ks ../../../config/sgadmin.jks -kspass $KS_PASS -cn $CLUSTER_NAME \
   -nhnv -cd ../sgconfig/ -h `hostname -f`
