FROM mysql:5.7.24
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

#ADD sql/* /sql/
#ADD gen_sql/* /tmp/gen_sql/

ENV MYSQL_ROOT_PASSWORD=Cloudwiz_p0c

ADD entrypoint.sh /tmp/entrypoint.sh
ADD mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
RUN chmod a+x /tmp/entrypoint.sh
CMD ["mysqld"]
ENTRYPOINT ["/tmp/entrypoint.sh"]
