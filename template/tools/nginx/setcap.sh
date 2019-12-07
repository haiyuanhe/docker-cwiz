#!/bin/bash

SETCAP=/sbin/setcap

if [ ! -x "$SETCAP" ]; then
    SETCAP=/usr/sbin/setcap
fi

if [ "<:nginx_port:>" -le "1024" -o "<:nginx_ext_port:>" -le "1024" ]; then
    sudo $SETCAP cap_net_bind_service=+ep <:install_root:>/nginx/sbin/nginx
fi

exit 0
