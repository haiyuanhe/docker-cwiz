FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV HBASE_VERSION  1.4.10
ENV HBASE_URL ${PKG_URL:-http://download.cloudwiz.cn/package}/hbase-$HBASE_VERSION-bin.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$HBASE_URL" -o /tmp/hbase.tar.gz \
    && tar -xvf /tmp/hbase.tar.gz -C /opt/ \
    && rm /tmp/hbase.tar.gz*

RUN ln -s /opt/hbase-$HBASE_VERSION/conf /etc/hbase
RUN mkdir /opt/hbase-$HBASE_VERSION/logs

RUN mkdir /hadoop-data

ENV HBASE_PREFIX=/opt/hbase-$HBASE_VERSION
ENV HBASE_CONF_DIR=/etc/hbase

ENV USER=root
ENV PATH $HBASE_PREFIX/bin/:$PATH

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
