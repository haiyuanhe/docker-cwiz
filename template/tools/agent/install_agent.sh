#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/../common/utils.sh

mkdir -p <:agent_root:>

if [ $? -ne 0 ]; then
    echo "Failed to create directory <:agent_root:>! Abort!"
    exit 1
fi

# delete /tmp/agent.tar.gz and /tmp/agent.tar.gz.md5 if necessary
# because deploy_agent.sh will try to download a new version of
# the agent to that location.
rm -f /tmp/agent.tar.gz

if [ $? -ne 0 ]; then
    echo "Please delete /tmp/agent.tar.gz and try again."
    exit 2
fi

rm -f /tmp/agent.tar.gz.md5

if [ $? -ne 0 ]; then
    echo "Please delete /tmp/agent.tar.gz.md5 and try again."
    exit 3
fi

if is_ipv6 "<:agent_ip:>"; then
    CURL_OPT="-6gskL"
else
    CURL_OPT="-skL"
fi

ORG_TOKEN=<:token:> CLIENT_ID=1 SYSTEM_ID=1 METRIC_SERVER_HOST=<:agent_ip:> ALERTD_SERVER=<:agent_protocol:>://<:agent_ip:>:<:agent_port:>/_alertd AGENT_URL=<:agent_protocol:>://<:agent_ip:>:<:agent_port:>/agent INSTALL_DIR=<:agent_root:> PORT=<:agent_port:> bash -c "$(curl $CURL_OPT <:agent_protocol:>://<:agent_ip:>:<:agent_port:>/agent/deploy_agent.sh)"

exit 0
