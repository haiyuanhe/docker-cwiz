FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-permission.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-permission.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/cloudwiz-permission.tar.gz -C ${INSTALL_ROOT} \
    && mv ${INSTALL_ROOT}/cloudwiz-permission ${INSTALL_ROOT}/permission \
    && rm /tmp/cloudwiz-permission.tar.gz* \
    && ln -s /usr/lib/jvm/java  ${INSTALL_ROOT}/jdk


ENV USER=root

EXPOSE 4123

CMD ${INSTALL_ROOT}/permission/bin/start.sh
