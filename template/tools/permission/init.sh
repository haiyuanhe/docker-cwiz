#!/bin/bash

curl -X POST "http://<:nginx_ip:>:4124/init/role"
curl -X POST "http://<:nginx_ip:>:4124/init/role/0"
curl -X POST "http://<:nginx_ip:>:4124/init/system_user/0"
curl -X POST "http://<:nginx_ip:>:4124/init/org/datasource"
