#!/bin/bash

echo "Waiting for nginx to start"

started=false
url="http://<:nginx_ip:>:<:nginx_port:>/agent/deploy_agent.sh"

while [ $started == false ]
do
    if curl --output /dev/null --silent --head --fail "$url"; then
        echo
        echo "Nginx is running"
        break
    else
        sleep 5
        printf '.'
    fi
done

exit 0
