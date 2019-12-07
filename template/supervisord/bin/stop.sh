#!/bin/bash

/bin/kill `cat <:install_root:>/supervisord/altenv/var/run/supervisord.pid`

exit 0
