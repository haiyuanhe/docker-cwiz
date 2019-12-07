#!/bin/bash

<:install_root:>/nginx/sbin/nginx -p <:install_root:>/nginx -c <:install_root:>/nginx/conf/nginx.conf -s reload
