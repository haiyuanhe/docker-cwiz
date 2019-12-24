#!/bin/bash

. <:install_root:>/tools/crypt/utils.sh

echo "======================================================================================"
echo "CREATE MYSQL Certificates and Keys"
echo "======================================================================================"

decrypt_SSLPass

if [ "abc$1" = "abc" ]; then
    store_pass=${ssl_decrypt_pass}
else
    store_pass=$1
fi

keytool_path=<:install_root:>/encrypt/jdk/bin/keytool

unset ssl_decrypt_pass

mkdir -p <:install_root:>/certs/mysql
cp <:install_root:>/data/mysql/*.pem <:install_root:>/certs/mysql/
cd <:install_root:>/certs/mysql

echo y | $keytool_path -importcert -alias MySQLCACert -file ca.pem -keystore truststore.jks -storepass $store_pass
openssl pkcs12 -export -in client-cert.pem -inkey client-key.pem -out client.p12 -name "mysqlclient" -passout pass:$store_pass
$keytool_path -importkeystore -srckeystore client.p12 -srcstoretype pkcs12 -srcstorepass $store_pass -destkeystore client.jks -deststoretype pkcs12 -deststorepass $store_pass
