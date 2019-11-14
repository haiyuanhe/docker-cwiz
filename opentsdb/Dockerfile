FROM cloudwiz/openjdk:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV OPENTSDB_URL ${PKG_URL:-http://download.cloudwiz.cn/package}/opentsdb.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java
ENV USER=root

RUN set -x \
    && curl -fSL "$OPENTSDB_URL" -o /tmp/opentsdb.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/opentsdb.tar.gz -C ${INSTALL_ROOT} \
    && rm /tmp/opentsdb.tar.gz*


ADD start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 4242

ENTRYPOINT /wait-for-it.sh mysql:3306 --timeout=5 -- /start.sh
