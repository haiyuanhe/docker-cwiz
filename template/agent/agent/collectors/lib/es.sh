#!/bin/bash

TS=$(date +%s)
DOCS=( $(/opt/tools/elasticsearch/ls-index.sh | awk '{print $7}') )

total=0
for n in ${DOCS[@]}; do
    (( total += n ))
done

echo "elasticsearch.docs.count $TS $total"
