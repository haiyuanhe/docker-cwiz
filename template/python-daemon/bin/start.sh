#!/bin/bash

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:<:install_root:>/python-daemon/pythondenv/usr/local/ssl/lib
export PYTHONPATH=<:install_root:>/python-daemon/pythond/pythond

<:install_root:>/python-daemon/pythondenv/bin/gunicorn -c <:install_root:>/python-daemon/pythond/pythond/gunicorn.conf.py --env DJANGO_SETTINGS_MODULE=pythond.settings pythond.wsgi

exit 0
