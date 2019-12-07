#!/bin/bash

_CONFIGS=("<:install_root:>/alertd/conf/cloudmon.alerting.conf" "<:install_root:>/cmservice/conf/cmservice.properties" "<:install_root:>/log-analysis/config/log.clustering.properties" "<:install_root:>/log-pp/config/log.pp.properties" "<:install_root:>/log-processor/config/log.processor.properties" "<:install_root:>/metric-proxy/config/application.yml" "<:install_root:>/opentsdb/conf/opentsdb.conf" "<:install_root:>/permission/config/application.yml" "<:install_root:>/tools/mysql/wait_for_mysql.sh" "<:install_root:>/umanager/bin/get_tokens.sh" "<:install_root:>/umanager/bin/um_daemon.py" "<:install_root:>/webfront/conf/defaults.ini")


# Ask for current MySQL credentials
read -p "Please enter current MySQL username: " _current_username

if [ -z "$_current_username" ]; then
    echo "Empty username entered. Abort."
    exit 1
fi

read -s -p "Please enter current MySQL password: " _current_password
echo

if [ -z "$_current_password" ]; then
    echo "Empty password entered. Abort."
    exit 2
fi

# Ask for new MySQL credentials
read -p "Please enter new MySQL username: " _new_username

if [ -z "$_new_username" ]; then
    echo "Empty username entered. Abort."
    exit 3
fi

read -s -p "Please enter new MySQL password: " _new_password
echo

if [ -z "$_new_password" ]; then
    echo "Empty password entered. Abort."
    exit 4
fi

_current_password=$(echo -n "$_current_password" | base64)
_new_password=$(echo -n "$_new_password" | base64)

for cfg in ${_CONFIGS[@]}; do
    if [ "$_current_username" != "$_new_username" ]; then
        sed -i "s/$_current_username/$_new_username/g" $cfg
        if [ $? -ne 0 ]; then
            echo "Failed to update ${cfg}. Abort!"
            exit 5
        fi
    fi
    if [ "$_current_password" != "$_new_password" ]; then
        sed -i "s/$_current_password/$_new_password/g" $cfg
        if [ $? -ne 0 ]; then
            echo "Failed to update ${cfg}. Abort!"
            exit 6
        fi
    fi
    echo "Successfully updated $cfg"
done

exit 0
