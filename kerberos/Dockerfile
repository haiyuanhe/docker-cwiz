FROM centos:6.6

LABEL Name="hb" \
      Version="1.0"

# kerberos
RUN yum install -y krb5-server krb5-libs krb5-workstation

RUN mkdir /kerberos

EXPOSE 88 749

ADD ./config.sh /config.sh

ENTRYPOINT ["./config.sh"]