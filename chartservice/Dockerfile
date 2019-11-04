FROM cloudwiz/openjdk:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-chart-service.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-chart-service.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/cloudwiz-chart-service.tar.gz -C ${INSTALL_ROOT} \
    && mv ${INSTALL_ROOT}/cloudwiz-chart-service ${INSTALL_ROOT}/chartservice \
    && rm /tmp/cloudwiz-chart-service.tar.gz* \
    && ln -s /usr/lib/jvm/java  ${INSTALL_ROOT}/jdk \
    && mkdir -p ${INSTALL_ROOT}/report_tmp/


ENV USER=root

EXPOSE 5012

CMD ${INSTALL_ROOT}/chartservice/bin/start.sh
