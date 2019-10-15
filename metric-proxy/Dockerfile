FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-metric-proxy.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-metric-proxy.tar.gz \
    && tar -xvf /tmp/cloudwiz-metric-proxy.tar.gz -C /opt/ \
    && mv /opt/cloudwiz-metric-proxy /opt/metric-proxy \
    && mkdir -p /opt/metric-proxy/config \
    && rm /tmp/cloudwiz-metric-proxy.tar.gz* \
    && ln -s /usr/lib/jvm/java  /opt/jdk


ENV USER=root

EXPOSE 4243

CMD ["/opt/metric-proxy/bin/start.sh"]
