#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/../common/utils.sh

check_url '<:nginx_protocol:>://<:nginx_ip:>:<:nginx_port:>/_tsdb/'

if [ $? -eq 0 ]; then
    echo "I'm ready."
fi

exit 0
