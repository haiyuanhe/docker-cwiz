FROM mysql:5.7.28
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ENV MYSQL_ROOT_PASSWORD=Cloudwiz_p0c
RUN apt-get update && apt-get install -y procps && apt-get install -y gawk
RUN rm $HOME/.mysql_history  && ln -s /dev/null $HOME/.mysql_history
RUN usermod -s /bin/false mysql && usermod -s /sbin/nologin mysql

RUN chmod 600 /et/mysql/mysql.conf.d/mysqld.cnf
RUN chmod 700 /var/lib/mysql
RUN chown -R mysql:mysql /var/lib/mysql
RUN chmod 600 /var/log/mysql/
RUN chown -R mysql:mysql /var/log/mysql/

RUN mkdir /logs
RUN chmod 600 /logs
RUN chown -R mysql:mysql /logs

ADD entrypoint.sh /tmp/entrypoint.sh
ADD mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
RUN chmod a+x /tmp/entrypoint.sh
CMD ["mysqld"]
ENTRYPOINT ["/tmp/entrypoint.sh"]
