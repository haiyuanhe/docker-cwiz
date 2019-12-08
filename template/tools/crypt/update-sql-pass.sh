#!/bin/bash

echo "======================================================================================"
echo "NOTE: This will update MySQL Pass "
echo "======================================================================================"

read -p "Are you sure to update MySQL Pass (y|n): " ans
echo -e "\n"

if [ "$ans" = "y" ]; then
    # get old mysql pass
    source <:install_root:>/tools/crypt/utils.sh
    decrypt_MySQLPass

    # get new mysql pass
    read -s -p "Please input MySQL old Pass:  " old_pass
    echo -e "\n"
    if [ "${old_pass}" != "${decrypt_pass}" ]; then
        echo "ERROR: MySQL password not correct!"
        exit 2
    fi
    # get new mysql pass
    while true
        do
            read -s -p "Please input the new MySQL Pass: " pass1
            echo -e "\n"
            read -s -p "Please input the new MySQL Pass again: " pass2
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

    # update mysql pass in database
    echo "new_pass: ${new_pass}"
    echo "old_pass: ${decrypt_pass}"
    sql="set password for 'CloudInsight'@'172.19.%' = password('${new_pass}');flush privileges;"
    echo $sql
    docker exec -it mysql-server /bin/bash -c "/usr/bin/mysql -h 172.19.0.7 -uCloudInsight -p${decrypt_pass} -e \"${sql}\""
    if [ "$?" != "0" ]; then
        echo "ERROR: update mysql password failed !!"
        exit 2
    fi
    unset decrypt_pass
    #set password for 'CloudInsight'@'%' = password('Cloudwiz_1111');
    #flush privileges;

    # encrypt new pass
    java_path="<:install_root:>/encrypt/jdk/bin/java"
    crypt_jar="<:install_root:>/encrypt/cloudwiz-crypt-1.0-SNAPSHOT-jar-with-dependencies.jar"
    java_class="com.cloudwiz.crypt.AesCrypt"
    secret_key="DBj1X8tVSUnQGfSdbo1LhgzjFPa5yUYA"
    mysql_password=${new_pass}
    encrypt_mysql_pass=$(${java_path} -cp ${crypt_jar} ${java_class} ${secret_key} encrypt ${mysql_password})

    # udpate mysql pass in configs
    echo "update configs ..."

    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/alertd/conf/cloudmon.alerting.conf && echo "yes"
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/log-analysis/config/log.analysis.properties  && echo "yes"
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/log-pp/config/log.pp.properties
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/log-processor/config/log.processor.properties
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/metric-proxy/config/application.yml
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/oneagent/conf/application.yml
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/permission/config/application.yml
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/python-daemon/pythond/pythond/init_config.ini
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/webfront/conf/defaults.ini
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/tools/crypt/utils.sh
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/tools/setup/verify_etc_hosts.sh
    sed -i "s%${mysql_old_password}%${encrypt_mysql_pass}%g" <:install_root:>/umanager/bin/um_daemon.py

else
    exit 0
fi



