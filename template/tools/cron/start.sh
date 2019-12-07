#!/bin/bash

crontab -l | grep 'run-parts'

if [ $? -ne 0 ]; then
    (crontab -l 2>/dev/null; echo "17 * * * * cd / && run-parts <:install_root:>/tools/cron/cron.hourly") | crontab -
    (crontab -l 2>/dev/null; echo "25 2 * * * cd / && run-parts <:install_root:>/tools/cron/cron.daily") | crontab -
    (crontab -l 2>/dev/null; echo "45 1 * * 7 cd / && run-parts <:install_root:>/tools/cron/cron.weekly") | crontab -
fi

crontab -l | grep 'reboot'

if [ $? -ne 0 ]; then
    (crontab -l 2>/dev/null; echo "@reboot <:install_root:>/supervisord/bin/start.sh") | crontab -
fi

exit 0
