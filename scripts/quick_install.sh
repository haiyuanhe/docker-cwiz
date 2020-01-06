#!/bin/bash

read -p "Please input the local ip: " local_ip
echo -e "\n"
read -p "Please input the CloudOps url: " huawei_url
echo -e "\n"

sed -i '/^huawei_url =/chuawei_url = ${huawei_url}' ./install.ini
sed -i '/^nginx_ext_ip =/cnginx_ext_ip = ${$local_ip}' ./install.ini
sed -i '/^docker_host_int_ip =/cdocker_host_int_ip = ${$local_ip}' ./install.ini


./install-all.sh ./install.ini