#!/bin/bash

AGENT_ROOT="<:agent_root:>"
FILE=$(ls <:install_root:>/webfront/public/build/app.*.js)

sed -i "s/ bash -c / INSTALL_DIR=${AGENT_ROOT//\//\\/} bash -c /" $FILE
sed -i "s/\/opt\/cloudwiz-agent\//${AGENT_ROOT//\//\\/}\/cloudwiz-agent\//g" $FILE
sed -i "s/{{alertServer}} \.\/deploy_agent.sh/{{alertServer}} INSTALL_DIR=${AGENT_ROOT//\//\\/} \.\/deploy_agent.sh/" $FILE

exit 0
