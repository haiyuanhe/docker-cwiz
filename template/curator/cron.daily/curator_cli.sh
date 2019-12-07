#!/bin/bash

if [ -z "$CURATOR_DAYS_TO_KEEP" ]; then
    CURATOR_DAYS_TO_KEEP=30
fi

<:install_root:>/curator/curator_cli --host <:nginx_ip:> --port 9202 --loglevel INFO --logfile <:log_root:>/curator/curator.log delete_indices --ignore_empty_list --filter_list '[{"filtertype":"age","source":"name","direction":"older","timestring":"%Y.%m.%d","unit":"days","unit_count":'$CURATOR_DAYS_TO_KEEP'},{"filtertype":"pattern","kind":"prefix","value":"^[0-9a-f]{32}-logstash-"}]'
