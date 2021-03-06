#!/bin/bash
read -p "Please input the local ip: " local_ip
read -r -p "Is the local IP the same as the external IP (EIP) ? [y/N] " input
case $input in
    [yY][eE][sS]|[yY])
		eip=$local_ip
		;;

    [nN][oO]|[nN])
       	read -p "Please input the external IP (EIP): " eip
       	;;

    *)
	echo "Invalid input..."
	exit 1
	;;
esac
read -p "Please input the CloudOps virtual url: " huawei_url
read -p "Please input the CloudOps access key : " ak
read -p "Please input the CloudOps secret key : " sk

echo "local ip:             ${local_ip}"
echo "external IP (EIP):    ${eip}"
echo "CloudOps virtual URL: ${huawei_url}"
echo "CloudOps access key:  ${ak}"
echo "CloudOps secret key:  ${sk}"

sed -i "/^huawei_url =/chuawei_url = ${huawei_url}" ./install.ini
sed -i "/^huawei_ak =/chuawei_ak = ${ak}" ./install.ini
sed -i "/^huawei_sk =/chuawei_sk = ${sk}" ./install.ini
sed -i "/^nginx_ext_ip =/cnginx_ext_ip = ${eip}" ./install.ini
sed -i "/^docker_host_int_ip =/cdocker_host_int_ip = ${local_ip}" ./install.ini

read -n 1 -p "Press any key to continue..."
./install-all.sh ./install.ini