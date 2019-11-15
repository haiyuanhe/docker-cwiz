FROM mysql:5.7.28
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ENV USER=mysql

ENV MYSQL_ROOT_PASSWORD=Cloudwiz_huawei_p0c
RUN apt-get update && apt-get install -y procps && apt-get install -y gawk
RUN usermod -s /bin/false mysql && usermod -s /sbin/nologin mysql

RUN mkdir /logs
RUN chmod 600 /logs
RUN chown -R mysql:mysql /logs

ADD entrypoint.sh /tmp/entrypoint.sh
RUN chmod a+x /tmp/entrypoint.sh
CMD ["mysqld"]
ENTRYPOINT ["/tmp/entrypoint.sh"]
