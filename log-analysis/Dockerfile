FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-log-analysis.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-log-analysis.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/cloudwiz-log-analysis.tar.gz -C ${INSTALL_ROOT} \
    && mv ${INSTALL_ROOT}/cloudwiz-log-analysis ${INSTALL_ROOT}/log-analysis \
    && rm /tmp/cloudwiz-log-analysis.tar.gz* \
    && ln -s /usr/lib/jvm/java  ${INSTALL_ROOT}/jdk


ENV USER=root

EXPOSE 9400

CMD ${INSTALL_ROOT}/log-analysis/bin/start.sh
