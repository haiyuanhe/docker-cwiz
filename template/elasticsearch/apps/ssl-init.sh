#!/bin/bash
KS_PASS='<:ssl_password:>'
TS_PASS=$KS_PASS
CLUSTER_NAME='cloudwiz'

# init ssl
cd /usr/share/elasticsearch/plugins/search-guard-5/tools
sh ./sgadmin.sh -ts ../../../config/truststore.jks -tspass $TS_PASS \
   -ks ../../../config/sgadmin.jks -kspass $KS_PASS -cn $CLUSTER_NAME \
   -nhnv -cd ../sgconfig/ -h `hostname -f`
