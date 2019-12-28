#!/bin/bash
ak=468f917903df145ee2e9
sk=1297d4cbc503fbf25d36335b2e4e3993
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
read -p "Please input the CloudOps local url: " huawei_url
read -p "Please input the CloudOps virtual url: " huawei_vurl
read -p "Please input the CloudOps access key [468f917903df145ee2e9]: " akinput
if [ ! -n "$akinput" ]; then
    ak=468f917903df145ee2e9
else
    ak=$akinput
fi
read -p "Please input the CloudOps secret key [1297d4cbc503fbf25d36335b2e4e3993]: " skinput
if [ ! -n "$skinput" ]; then
    sk=1297d4cbc503fbf25d36335b2e4e3993
else
    sk=$skinput
fi

echo "local ip:             ${local_ip}"
echo "external IP (EIP):    ${eip}"
echo "CloudOps local URL:   ${huawei_url}"
echo "CloudOps virtual URL: ${huawei_vurl}"
echo "CloudOps access key:  ${ak}"
echo "CloudOps secret key:  ${sk}"

sed -i "/^huawei_url =/chuawei_url = ${huawei_url}" ./install.ini
sed -i "/^huawei_vurl =/chuawei_vurl = ${huawei_vurl}" ./install.ini
sed -i "/^huawei_ak =/chuawei_ak = ${ak}" ./install.ini
sed -i "/^huawei_sk =/chuawei_sk = ${sk}" ./install.ini
sed -i "/^nginx_ext_ip =/cnginx_ext_ip = ${eip}" ./install.ini
sed -i "/^docker_host_int_ip =/cdocker_host_int_ip = ${local_ip}" ./install.ini

read -n 1 -p "Press any key to continue..."
./install-all.sh ./install.ini