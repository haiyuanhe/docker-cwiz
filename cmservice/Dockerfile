FROM cloudwiz/openjdk:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-cm-service.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-cm-service.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/cloudwiz-cm-service.tar.gz -C ${INSTALL_ROOT} \
    && mv ${INSTALL_ROOT}/cloudwiz-cm-service ${INSTALL_ROOT}/cmservice \
    && mkdir -p ${INSTALL_ROOT}/cmservice/config \
    && rm /tmp/cloudwiz-cm-service.tar.gz*

ENV USER=root

EXPOSE 9601

CMD ${INSTALL_ROOT}/cmservice/bin/start.sh
