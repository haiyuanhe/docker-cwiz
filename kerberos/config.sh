#!/bin/bash

[[ "TRACE" ]] && set -x

: ${KERBEROS_REALM:=CWIZ.COM}
: ${DOMAIN_REALM:=cwiz.com}
: ${KERB_MASTER_KEY:=Cwiz_p0c}
: ${KERB_ADMIN_USER:=admin}
: ${KERB_ADMIN_PASS:=admin}
: ${SEARCH_DOMAINS:=cwiz.com}

fix_nameserver() {
  cat>/etc/resolv.conf<<EOF
nameserver $NAMESERVER_IP
search $SEARCH_DOMAINS
EOF
}

fix_hostname() {
  sed -i "/^hosts:/ s/ *files dns/ dns files/" /etc/nsswitch.conf
}

create_krb5_config() {
  : ${KDC_ADDRESS:=$(hostname -f)}

  cat>/etc/krb5.conf<<EOF
[logging]
 default = FILE:/var/log/kerberos/krb5libs.log
 kdc = FILE:/var/log/kerberos/krb5kdc.log
 admin_server = FILE:/var/log/kerberos/kadmind.log
[libdefaults]
 default_realm = $KERBEROS_REALM
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 7d
 renew_lifetime = 30d
 forwardable = true
[realms]
 $KERBEROS_REALM = {
  kdc = $KDC_ADDRESS
  admin_server = $KDC_ADDRESS
 }
[domain_realm]
 .$DOMAIN_REALM = $KERBEROS_REALM
 $DOMAIN_REALM = $KERBEROS_REALM
EOF
}

create_kdc_config() {
  cat>/var/kerberos/krb5kdc/kdc.conf<<EOF
[kdcdefaults]
 kdc_ports = 88
 kdc_tcp_ports = 88

[realms]
 $KERBEROS_REALM = {
  #master_key_type = aes256-cts
  acl_file = /var/kerberos/krb5kdc/kadm5.acl
  dict_file = /usr/share/dict/words
  admin_keytab = /var/kerberos/krb5kdc/kadm5.keytab
  # Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files
  # for JDK/JRE 7 must be installed in order to use 256-bit AES encryption (aes256-cts:normal)
  supported_enctypes = des3-hmac-sha1:normal arcfour-hmac:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal
  max_life = 30d
  max_renewable_life = 30d
 }
EOF
}

create_db() {
  /usr/sbin/kdb5_util -P $KERB_MASTER_KEY -r $KERBEROS_REALM create -s
}

start_kdc() {
  mkdir -p /var/log/kerberos

  /etc/rc.d/init.d/krb5kdc start
  /etc/rc.d/init.d/kadmin start

  chkconfig krb5kdc on
  chkconfig kadmin on
}

restart_kdc() {
  /etc/rc.d/init.d/krb5kdc restart
  /etc/rc.d/init.d/kadmin restart
}

create_admin_user() {
  kadmin.local -q "addprinc -pw $KERB_ADMIN_PASS $KERB_ADMIN_USER/admin"
  echo "*/admin@$KERBEROS_REALM *" > /var/kerberos/krb5kdc/kadm5.acl
}

init_script() {
  echo $KERBEROS_PRIMARY
  for svc in ${KERBEROS_PRIMARY}; do
      if [[ -f "/kerberos/${svc}.keytab" ]];then
            echo "Alreay exists[/kerberos/${svc}.keytab]. will re-created."
            rm -f /kerberos/${svc}.keytab
      fi
      for _h in ${KERBEROS_HOST}; do
          kadmin -p ${KERB_ADMIN_USER}/admin@${KERBEROS_REALM} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey ${svc}/${_h}@${KERBEROS_REALM}"
          kadmin -p ${KERB_ADMIN_USER}/admin@${KERBEROS_REALM} -w ${KERB_ADMIN_PASS} -q "xst -k /kerberos/${svc}.keytab ${svc}/${_h}@${KERBEROS_REALM}"
      done
  done
}

main() {
  fix_nameserver
  fix_hostname

  if [ ! -f /kerberos_initialized ]; then
    create_krb5_config
    create_kdc_config
    create_db
    create_admin_user
    start_kdc

    init_script

    touch /kerberos_initialized
  fi


  if [ ! -f /var/kerberos/krb5kdc/principal ]; then
    while true; do sleep 1000; done
  else
    start_kdc
    tail -F /var/log/kerberos/krb5kdc.log
  fi
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"