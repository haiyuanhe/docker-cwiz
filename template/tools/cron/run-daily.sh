#!/bin/bash

crontab -l | grep 'run-parts'

# if cron jobs were not installed successfully...
if [ $? -ne 0 ]; then
    cd / && run-parts <:install_root:>/tools/cron/cron.daily
fi

# sleep for 1 day
sleep 86400

exit 0
