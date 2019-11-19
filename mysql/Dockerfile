FROM mysql:5.7.28
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ENV USER=root

RUN apt-get update && apt-get install -y procps && apt-get install -y gawk
RUN usermod -s /bin/false mysql && usermod -s /sbin/nologin mysql

ADD mysqld.cnf /etc/mysql/my.cnf
ADD entrypoint.sh /tmp/entrypoint.sh
RUN chmod a+x /tmp/entrypoint.sh
CMD ["mysqld","--defaults-file=/etc/mysql/my.cnf"]
ENTRYPOINT ["/tmp/entrypoint.sh"]
