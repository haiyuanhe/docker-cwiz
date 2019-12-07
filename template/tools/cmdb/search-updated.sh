#!/bin/bash

curl -s -XPOST -H "Content-Type: application/json" http://<:nginx_ip:>:<:nginx_port:>/_cmdb/ci/1/1/updated -d "{'type':'Configuration','from':'2017-10-23T11:26:39Z','attributes':[{'name':'type','value':'log-processor','type':'None'}]}"

echo
exit 0
