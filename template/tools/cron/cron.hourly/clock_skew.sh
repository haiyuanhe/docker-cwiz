#!/bin/bash

_ALL_HOSTS=(<:all_hosts:>)
_NGINX_IP=<:nginx_ip:>
_HOST_IP=<:host_ip:>
_HOST_CNT=${#_ALL_HOSTS[@]}

_METRICS_URL="<:nginx_protocol:>://<:nginx_ip:>:<:nginx_port:>/_metrics/api/put?details"
_TOKEN=<:token:>

# for single host install, do nothing
if [ $_HOST_CNT -le 1 ]; then
    exit 0
fi

for i in {1..6}; do

    _TS=$(date +%s)

    # generate hosts file
    _TEMP=$(mktemp)
    date +%s >> $_TEMP

    # upload hosts file
    curl -k --fail --max-time 5 --upload-file $_TEMP <:nginx_protocol:>://$_NGINX_IP:8000/clock/$_HOST_IP/clock 2>/dev/null

    # detect clock skew
    if [ "$_HOST_IP" = "$_NGINX_IP" ]; then
        for host in ${_ALL_HOSTS[@]}; do
            _CLOCK_FILE=<:install_root:>/nginx/upload/clock/$host/clock

            if [ ! -f $_CLOCK_FILE ]; then
                continue
            fi

            _INSIDE=$(cat $_CLOCK_FILE)
            _OUTSIDE=$(date +%s -r $_CLOCK_FILE)

            if [ $_OUTSIDE -ge $_INSIDE ]; then
                _DIFF=$(( _OUTSIDE - _INSIDE ))
            else
                _DIFF=$(( _INSIDE - _OUTSIDE ))
            fi

            # send the metrics to opentsdb
            curl -sk -H "Content-Type: application/json" -H "_token: $_TOKEN" -XPOST "$_METRICS_URL" -d "{\"token\":\"$_TOKEN\",\"metrics\":[{\"metric\":\"cloudwiz.clock_skew\",\"value\":$_DIFF,\"timestamp\":$_TS,\"tags\":{\"host\":\"$host\"}}]}"
        done
    fi

    rm -f $_TEMP
    sleep 600
done

exit 0
