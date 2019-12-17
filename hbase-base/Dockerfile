FROM cloudwiz/openjdk:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV HBASE_VERSION  1.4.10
ENV HBASE_URL ${PKG_URL:-http://download.cloudwiz.cn/package}/hbase-$HBASE_VERSION-bin.tar.gz
ENV JAVA_HOME ${INSTALL_ROOT}/jdk

RUN apt-get -y update && apt-get install -y net-tools netcat perl \
    && apt-get clean all \
    && rm -rf /var/cache/

RUN set -x \
    && curl -fSL "$HBASE_URL" -o /tmp/hbase.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -zxvf /tmp/hbase.tar.gz -C ${INSTALL_ROOT} \
    && rm -rf ${INSTALL_ROOT}/hbase-$HBASE_VERSION/docs \
    && rm -rf /tmp/hbase.tar.gz*

RUN ln -s ${INSTALL_ROOT}/hbase-$HBASE_VERSION/conf /etc/hbase
RUN mkdir ${INSTALL_ROOT}/hbase-$HBASE_VERSION/logs

RUN mkdir /hadoop-data

ENV HBASE_PREFIX=${INSTALL_ROOT}/hbase-$HBASE_VERSION
ENV HBASE_CONF_DIR=/etc/hbase

ENV USER=root
ENV PATH $HBASE_PREFIX/bin/:$PATH

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
