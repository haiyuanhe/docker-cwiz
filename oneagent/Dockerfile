FROM cloudwiz/openjdk:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/oneagent.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/oneagent.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/oneagent.tar.gz -C ${INSTALL_ROOT} \
    && rm /tmp/oneagent.tar.gz*

ENV USER=root

EXPOSE 8888

CMD ${INSTALL_ROOT}/oneagent/bin/start.sh
