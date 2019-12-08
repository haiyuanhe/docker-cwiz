#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/common.sh

# make sure Elasticsearch is ready
echo "Waiting for Elasticsearch to get ready..."
while [ 1 ]
do
    _es_url="http://<:nginx_ip:>:9202/_cluster/health"
    curl -s "$_es_url" | grep "green"

    if [ $? -eq 0 ]; then
        echo "Elasticsearch is ready"
        sleep 2
        break
    else
        echo "Elasticsearch is not ready"
        sleep 10
    fi
done

echo "Elasticsearch is now ready!"

exit 0
