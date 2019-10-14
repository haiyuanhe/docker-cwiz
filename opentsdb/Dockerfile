FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV OPENTSDB_URL ${PKG_URL:-http://download.cloudwiz.cn/package}/opentsdb.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$OPENTSDB_URL" -o /tmp/opentsdb.tar.gz \
    && tar -xvf /tmp/opentsdb.tar.gz -C /opt/ \
    && rm /tmp/opentsdb.tar.gz* \
    && ln -s /usr/lib/jvm/java  /opt/jdk

ENV USER=root

EXPOSE 4242

CMD ["/opt/opentsdb/bin/start.sh"]
