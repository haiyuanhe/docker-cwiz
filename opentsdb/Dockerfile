FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>


ENV OPENTSDB_URL http://192.168.1.206:8080/package/opentsdb.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$HBASE_URL" -o /tmp/opentsdb.tar.gz \
    && tar -xvf /tmp/opentsdb.tar.gz -C /opt/ \
    && rm /tmp/opentsdb.tar.gz*

ENV USER=root

EXPOSE 4242

CMD ["/opt/bin/start.sh"]
