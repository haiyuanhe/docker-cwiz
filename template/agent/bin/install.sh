#!/bin/bash

sudo ORG_TOKEN=<:token:> CLIENT_ID=1 SYSTEM_ID=1 METRIC_SERVER_HOST=<:agent_ip:> ALERTD_SERVER=<:agent_protocol:>://<:agent_ip:>:<:agent_port:>/_alertd AGENT_URL=<:agent_protocol:>://<:agent_ip:>:<:agent_port:>/agent bash -c "$(curl -skL <:agent_protocol:>://<:agent_ip:>:<:agent_port:>/agent/deploy_agent.sh)"

exit 0
