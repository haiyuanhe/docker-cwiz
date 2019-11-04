FROM cloudwiz/openjdk:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/webfront.tar.gz
ENV USER=root

RUN set -x \
    && curl -fSL "$URL" -o /tmp/webfront.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/webfront.tar.gz -C ${INSTALL_ROOT} \
    && rm /tmp/webfront.tar.gz* \
    && mkdir /public

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000

ENTRYPOINT /start.sh
