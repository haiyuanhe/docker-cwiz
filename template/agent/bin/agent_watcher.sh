#!/bin/bash
# Start cloudwiz-agent, if it's not already started.

function is_agent_running()
{
    if [ ! -f <:agent_root:>/cloudwiz-agent/altenv/var/run/supervisord.pid ]; then
        return 1
    fi
    local pid=$(cat <:agent_root:>/cloudwiz-agent/altenv/var/run/supervisord.pid)
    ps -q $pid > /dev/null
    return $?
}

_TS=$(date --rfc-3339=seconds)

if is_agent_running; then
    echo "$_TS cloudwiz-agent is already running"
else
    echo "$_TS Starting cloudwiz-agent"
    <:agent_root:>/cloudwiz-agent/cloudwiz-agent start
fi

exit 0
