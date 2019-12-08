#!/bin/bash

. <:install_root:>/tools/crypt/utils.sh

echo "======================================================================================"
echo "NOTE: You need to download the JCE Unlimited Strength Jurisdiction Policy files from"
echo "http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html and"
echo "replace the local_policy.jar and US_export_policy.jar under $JDK/jre/lib/security."
echo "======================================================================================"

decrypt_SSLPass

host_ip=*
store_pass=${ssl_decrypt_pass}
keytool_path=<:install_root:>/encrypt/jdk/bin/keytool
server_conf_path=<:install_root:>/tools/certs/ssl/server.conf
client_conf_path=<:install_root:>/tools/certs/ssl/client.conf

unset ssl_decrypt_pass

mkdir -p <:install_root:>/certs
cd <:install_root:>/certs

servers=("nginx" "opentsdb" "cloudwiz-user" "alertd" "kafka" "python-deamon" "cloudwiz-agent" "cmservice" "log-analysis" "log-pp" "log-processor" "metric-proxy" "permission" "webfront" "mysql" "hbase" "zookeeper" "elastic")
for server in ${servers[@]}
do
mkdir $server
cd $server

#生成ca证书
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt << EOF
CN
Beijing
Beijing
Cloudwiz
Cloudwiz
root
cwiz@cloudwiz.cn
EOF

echo "C2E9862A0DA8E970" > serial
#生成服务端证书
openssl genrsa -out server.key 2048
#生成服务端签名请求文件
openssl req -new -key server.key -out server.csr -config $server_conf_path
#使用ca证书签名服务端证
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAserial serial -days 3650 -out server.crt -extensions v3_req -extfile $server_conf_path
#将服务端证书文件server.crt和服务端证书密钥文件server.key合并成服务端证书安装包server.p12
openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12 -passout pass:$store_pass
openssl pkcs8 -in server.key -topk8 -nocrypt -out server.p8
#生成服务器端keystore(server.jks)。使用keytool的importkeystore指令。pkcs12转jks。需要pkcs12密码和jks密码。
$keytool_path -importkeystore -srckeystore server.p12 -srcstoretype pkcs12 -srcstorepass $store_pass -destkeystore server.jks -deststoretype pkcs12 -deststorepass $store_pass


#生成客户端证书
openssl genrsa -out client.key 2048
#生成客户端签名请求文件
openssl req -new -key client.key -out client.csr -config $client_conf_path
#使用ca证书签名客户端证
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAserial serial -days 3650 -out client.crt -extensions v3_req -extensions usr_cert -extfile $client_conf_path
#将客户端证书文件client.crt和客户端证书密钥文件client.key合并成客户端证书安装包client.p12
openssl pkcs12 -export -in client.crt -inkey client.key -out client.p12 -passout pass:$store_pass
#生成客户端keystore(client.jks)。使用keytool的importkeystore指令。pkcs12转jks。需要pkcs12密码和jks密码。
$keytool_path -importkeystore -srckeystore client.p12 -srcstoretype pkcs12 -srcstorepass $store_pass -destkeystore client.jks -deststoretype pkcs12 -deststorepass $store_pass


#将服务端证书导入到客户端trustkeystore
echo y | $keytool_path -import -alias clientTrust -keystore clientTrust.jks -storepass $store_pass -file server.crt
#将客户端证书导入服务端trustkeystore
echo y | $keytool_path -import -alias serverTrust -keystore serverTrust.jks -storepass $store_pass -file client.crt
cd ../
done
