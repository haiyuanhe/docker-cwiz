#!/bin/bash

while [ 1 ]
do
    _status=$(curl -s -k -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d '{"metrics":[{"metric":"z.test","tags":{"mount":"C__"},"timestamp":1514736000,"value":0}],"token":"<:token:>"}' <:nginx_protocol:>://<:nginx_ip:>:<:nginx_port:>/_tsdb/api/put)


    if [ "$_status" -lt "300" ] && [ "$_status" -ge "200" ]; then
        echo
        echo "curl tag to opentsdb success!"
        break
    else
        sleep 5
        printf '.'
    fi
done

exit 0
~                                                                                                      
~                                                                                                      
~              
