#!/bin/bash

ES_URL=<:nginx_ip:>:9202
CURL="/usr/bin/curl -s"

SSH=/usr/bin/ssh
SSH_OPTS="-t -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

ELASTICDUMP=/usr/bin/elasticdump
SUPERVISORCTL=/usr/bin/supervisorctl

function one_required_arg() {
    if [ $# -lt 1 ]; then
        echo "required argument $1 missing"
        exit 1
    fi
    return 0
}

function two_required_arg() {
    if [ $# -lt 2 ]; then
        echo "required arguments ($1 or $2) missing"
        exit 1
    fi
    return 0
}

function control_elasticsearch() {
    local HOST=$1
    local CMD=$2

    $SSH $SSH_OPTS "root@$HOST" "$SUPERVISORCTL $CMD elasticsearch"
}

# 0 => GREEN; 1 => YELLOW; 2 => RED
function cluster_status() {
    local STATUS=$( $CURL $ES_URL/_cluster/health?pretty 2>/dev/null | grep status )
    if [[ "$STATUS" == *"green"* ]]; then
        return 0
    elif [[ "$STATUS" == *"yellow"* ]]; then
        return 1
    else
        return 2
    fi
}

# 0 => all; 1 => primaries; 2 => new_primaries; 3 => none
function cluster_routing_allocation_enable() {
    local SETTINGS=$( $CURL $ES_URL/_cluster/settings )
    if [[ "$SETTINGS" == *'"persistent":{"cluster":{"routing":{"allocation":{"enable":"all"}}}},'* ]]; then
        return 0
    elif [[ "$SETTINGS" == *'"persistent":{"cluster":{"routing":{"allocation":{"enable":"new_primaries"}}}},'* ]]; then
        return 2
    elif [[ "$SETTINGS" == *'"persistent":{"cluster":{"routing":{"allocation":{"enable":"primaries"}}}},'* ]]; then
        return 1
    elif [[ "$SETTINGS" == *'"persistent":{"cluster":{"routing":{"allocation":{"enable":"none"}}}},'* ]]; then
        return 3
    else
        return 0
    fi
}

function cluster_node_ips() {
    local IPS=$( $CURL $ES_URL/_nodes?pretty 2>/dev/null | grep '"ip"' | paste -sd ',' - )
    IPS=${IPS//,/}
    IPS=${IPS//:/}
    IPS=${IPS//\"/}
    IFS=' ' read -a ARRAY <<< "${IPS}"
    for ip in "${ARRAY[@]}"; do
        if [[ "$ip" != "ip" ]]; then
            NODES+=("$ip")
        fi
    done
}
