#!/bin/bash

# . <:install_root:>/tools/crypt/utils.sh
# decrypt_SSLPass
# if [ "abc$1" = "abc" ]; then
#     STOREPASS=${ssl_decrypt_pass}
# else
#     STOREPASS=$1
# fi
STOREPASS='Cloudwiz_p0c'
# rand (){
#   openssl rand -hex 20
# }

# export keytool=<:install_root:>/jdk/bin/keytool
export keytool=/usr/bin/keytool

# mkdir -p <:install_root:>/certs/kafka
# ROOT_CERT_PATH=<:install_root:>/certs/kafka
# clear old certs
# rm -rf <:install_root:>/certs/kafka/*
mkdir -p /Users/mars/dev/work/YunXing/source/docker-cwiz/test/certs/kafka
ROOT_CERT_PATH=/Users/mars/dev/work/YunXing/source/docker-cwiz/test/certs/kafka
rm -rf /Users/mars/dev/work/YunXing/source/docker-cwiz/test/certs/kafka/*

echo "password: $STOREPASS" > $ROOT_CERT_PATH/README.txt

# Kafka brokers
KAFKA_NODES=( kafka )

# 1.生成根证书
openssl req -new -x509 -keyout $ROOT_CERT_PATH/ca-key -out $ROOT_CERT_PATH/ca-cert -days 3652 -passout pass:$STOREPASS -subj "/C=CN/ST=Beijing/L=Beijing/O=Cloudwiz/OU=Cloudwiz/CN=Cloudwiz"

for HOSTNAME in ${KAFKA_NODES[@]}
do

CERT_PATH=$ROOT_CERT_PATH/$HOSTNAME
mkdir -p $CERT_PATH

# 2.Server
# 生成服务端 keystore
$keytool -keystore $CERT_PATH/server.jks -alias $HOSTNAME -validity 3650 -genkey -keypass $STOREPASS -keyalg RSA -dname "CN=$HOSTNAME,OU=Cloudwiz,O=Cloudwiz,L=Beijing,S=Beijing,C=CN" -storepass $STOREPASS -ext SAN=DNS:$HOSTNAME
# 创建服务端和客户端可信任证书
echo "y" | $keytool -keystore $CERT_PATH/serverTrust.jks -alias CARoot -import -file $ROOT_CERT_PATH/ca-cert -storepass $STOREPASS
echo "y" | $keytool -keystore $CERT_PATH/clientTrust.jks -alias CARoot -import -file $ROOT_CERT_PATH/ca-cert -storepass $STOREPASS
# 导出服务端证书
$keytool -keystore $CERT_PATH/server.jks -alias $HOSTNAME -certreq -file $CERT_PATH/server/server.cert-file -storepass $STOREPASS
# 使用CA证书签名
openssl x509 -req -CA $ROOT_CERT_PATH/ca-cert -CAkey $ROOT_CERT_PATH/ca-key -in $CERT_PATH/server/server.cert-file -out $CERT_PATH/server/server.cert-signed -days 3650 -CAcreateserial -passin pass:$STOREPASS
# 将根CA证书导入到服务端keystore
echo "y" | $keytool -keystore $CERT_PATH/server.jks -alias CARoot -import -file $ROOT_CERT_PATH/ca-cert -storepass $STOREPASS
# 将服务端CA证书导入到keystore
echo "y" | $keytool -keystore $CERT_PATH/server.jks -alias $HOSTNAME -import -file $CERT_PATH/server/server.cert-signed -storepass $STOREPASS

# 3.Client
# 生成客户端 keystore
$keytool -keystore $CERT_PATH/client.jks -alias $HOSTNAME -validity 3650 -genkey -keypass $STOREPASS -keyalg RSA -dname "CN=$HOSTNAME,OU=Cloudwiz,O=Cloudwiz,L=Beijing,S=Beijing,C=CN" -storepass $STOREPASS -ext SAN=DNS:$HOSTNAME
# 导出客户端证书
$keytool -keystore $CERT_PATH/client.jks -alias $HOSTNAME -certreq -file $CERT_PATH/client/client.cert-file -storepass $STOREPASS
# 使用CA证书签名
openssl x509 -req -CA $ROOT_CERT_PATH/ca-cert -CAkey $ROOT_CERT_PATH/ca-key -in $CERT_PATH/client/client.cert-file -out $CERT_PATH/client/client.cert-signed -days 3650 -CAcreateserial -passin pass:$STOREPASS
# 将根CA证书导入到客户端keystore
echo "y" | $keytool -keystore $CERT_PATH/client.jks -alias CARoot -import -file $ROOT_CERT_PATH/ca-cert -storepass $STOREPASS
# 将已签名证书导入到客户端keystore
echo "y" | $keytool -keystore $CERT_PATH/client.jks -alias $HOSTNAME -import -file $CERT_PATH/client/client.cert-signed -storepass $STOREPASS
#echo "y" | $keytool -keystore $CERT_PATH/client.jks -alias $HOSTNAME -import -file $CERT_PATH/server/server.cert-signed -storepass $STOREPASS

done

# update config: server.properties
function updateConfig() {
    key=$1
    value=$2
    file=$3

    # Omit $value here, in case there is sensitive information
    echo "[Configuring] '$key' in '$file'"

    # If config exists in file, replace it. Otherwise, append to file.
    if grep -E -q "^#?$key:" "$file"; then
        sed -r -i "s@^#?$key:.*@$key=$value@g" "$file" #note that no config values may contain an '@' char
    else
        echo "$key: $value" >> "$file"
    fi
}
CONFIG=<:install_root:>/kafka/config/server.properties
updateConfig "ssl.keystore.password" "$STOREPASS" "$CONFIG"
updateConfig "ssl.key.password" "$STOREPASS" "$CONFIG"
updateConfig "ssl.truststore.password" "$STOREPASS" "$CONFIG"
