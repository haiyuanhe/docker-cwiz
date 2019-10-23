FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/webfront.tar.gz
ENV USER=root

RUN set -x \
    && curl -fSL "$URL" -o /tmp/webfront.tar.gz \
    && tar -xvf /tmp/webfront.tar.gz -C /opt/ \
    && rm /tmp/webfront.tar.gz* \
    && mkdir /public

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000

ENTRYPOINT ["/start.sh"]
