FROM cloudwiz/openjdk:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-metric-proxy.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-metric-proxy.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/cloudwiz-metric-proxy.tar.gz -C ${INSTALL_ROOT}/ \
    && mv ${INSTALL_ROOT}/cloudwiz-metric-proxy ${INSTALL_ROOT}/metric-proxy \
    && mkdir -p ${INSTALL_ROOT}/metric-proxy/config \
    && rm /tmp/cloudwiz-metric-proxy.tar.gz*

ENV USER=root

EXPOSE 4243

CMD ${INSTALL_ROOT}/metric-proxy/bin/start.sh
