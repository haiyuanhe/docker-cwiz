FROM cloudwiz/openjdk:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-log-processor.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-log-processor.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/cloudwiz-log-processor.tar.gz -C ${INSTALL_ROOT} \
    && mv ${INSTALL_ROOT}/cloudwiz-log-processor ${INSTALL_ROOT}/log-processor \
    && mkdir -p ${INSTALL_ROOT}/log-processor/config \
    && rm /tmp/cloudwiz-log-processor.tar.gz*

ENV USER=root

#EXPOSE 9601

CMD ${INSTALL_ROOT}/log-processor/bin/start.sh
