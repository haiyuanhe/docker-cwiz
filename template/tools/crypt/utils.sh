#!/bin/bash

# 该加密方法尚未使用到
#encrypt MySQL password
function encrypt_MySQLPass()
{
    local java_path="<:install_root:>/encrypt/jdk/bin/java"
    local alertd_jar="<:install_root:>/encrypt/<:local_encrypt_jar:>"
    local java_class="com.cloudwiz.crypt.AesCrypt"
    local secret_key="<:secret_key:>"
    local mysql_password="<:mysql_password:>" #need change

    export encrypt_pass=$(${java_path} -cp ${alertd_jar} ${java_class} ${secret_key} encrypt ${mysql_password})
}


#decrypt MySQL password
function decrypt_MySQLPass()
{
    local java_path="<:install_root:>/encrypt/jdk/bin/java"
    local alertd_jar="<:install_root:>/encrypt/<:local_encrypt_jar:>"
    local java_class="com.cloudwiz.crypt.AesCrypt"
    local secret_key="<:secret_key:>"
    local mysql_password="<:mysql_password:>"
    export mysql_old_password="<:mysql_password:>"

    export decrypt_pass=$(${java_path} -cp ${alertd_jar} ${java_class} ${secret_key} decrypt ${mysql_password})
}

#decrypt SSL password
function decrypt_SSLPass()
{
    local java_path="<:install_root:>/encrypt/jdk/bin/java"
    local alertd_jar="<:install_root:>/encrypt/<:local_encrypt_jar:>"
    local java_class="com.cloudwiz.crypt.AesCrypt"
    local secret_key="<:secret_key:>"
    local ssl_password="<:ssl_password:>"
    export ssl_old_password="<:ssl_password:>"

    export ssl_decrypt_pass=$(${java_path} -cp ${alertd_jar} ${java_class} ${secret_key} decrypt ${ssl_password})
}
