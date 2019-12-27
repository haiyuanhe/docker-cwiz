#!/bin/bash


echo "======================================================================================"
echo "NOTE: This will recreate all certs "
echo "======================================================================================"

read -p "Are you sure to update all certs: (y|n): " ans

if [ "$ans" = "y" ]; then


    source <:install_root:>/tools/crypt/utils.sh
    decrypt_SSLPass

    # get new ssl pass
    read -s -p "Please input SSL old Pass:  " old_pass
    echo -e "\n"
    if [ "${old_pass}" != "${ssl_decrypt_pass}" ]; then
        echo "ERROR: SSL password not correct!"
        exit 2
    fi

    # get new ssl pass
    while true
        do
            read -s -p "Please input the new SSL Pass: " pass1
            echo -e "\n"
            read -s -p "Please input the new SSL Pass again: " pass2
            echo -e "\n"

            if [ "${pass1}" = "${pass2}" ]; then
                if [ "abc${pass1}" = "abc" ]; then
                   echo "ERROR:  The password can not be none!"
                   exit 2
                else
                   new_pass=${pass1}
                   break
                fi
            else
               echo "ERROR: The two passes is not the same!"
               exit 2
            fi
        done

    # backup odl ssl certs
    rm -rf  <:install_root:>/certs.bak
    mv <:install_root:>/certs <:install_root:>/certs.bak

    # generate new certs
    <:install_root:>/tools/certs/create-ssl-all-x.sh ${new_pass}


    # encrypt new pass
    java_path="<:install_root:>/encrypt/jdk/bin/java"
    crypt_jar="<:install_root:>/encrypt/cloudwiz-crypt-1.0-SNAPSHOT-jar-with-dependencies.jar"
    java_class="com.cloudwiz.crypt.AesCrypt"
    secret_key="DBj1X8tVSUnQGfSdbo1LhgzjFPa5yUYA"
    ssl_password=${new_pass}
    encrypt_ssl_pass=$(${java_path} -cp ${crypt_jar} ${java_class} ${secret_key} encrypt ${ssl_password})

    # update configs
    echo "update configs ..."

    sed -i "s%${ssl_old_password}%${encrypt_ssl_pass}%g" <:install_root:>/alertd/conf/cloudmon.alerting.conf 
    sed -i "s%${ssl_old_password}%${encrypt_ssl_pass}%g" <:install_root:>/cmservice/conf/cmservice.properties
    sed -i "s%${ssl_old_password}%${encrypt_ssl_pass}%g" <:install_root:>/log-analysis/config/log.analysis.properties
    sed -i "s%${ssl_old_password}%${encrypt_ssl_pass}%g" <:install_root:>/log-pp/config/log.pp.properties
    sed -i "s%${ssl_old_password}%${encrypt_ssl_pass}%g" <:install_root:>/log-processor/config/log.processor.properties
    sed -i "s%${ssl_old_password}%${encrypt_ssl_pass}%g" <:install_root:>/metric-proxy/config/application.yml
    sed -i "s%${ssl_old_password}%${encrypt_ssl_pass}%g" <:install_root:>/permission/config/application.yml
    sed -i "s%${ssl_old_password}%${encrypt_ssl_pass}%g" <:install_root:>/tools/crypt/utils.sh

    # es kafka ssl
    $(dirname $0)/es/gen-nodes-certs.sh
    $(dirname $0)/kafka/update-cert-conf.sh
else
    exit 0
fi
