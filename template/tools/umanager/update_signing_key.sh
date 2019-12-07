#!/bin/bash
# This script is only needed in QingCloud environment.

KEY=$(grep signing_key /opt/cloudwiz/umanager/config/umanager.conf|awk '{print $NF}')
sed -i "s/<signing_key>/$KEY/" /home/cwiz/qcloud/template/umanager/config/umanager.conf

exit 0
