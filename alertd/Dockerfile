FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-daemon.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java
ENV USER=root

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-daemon.tar.gz \
    && tar -xvf /tmp/cloudwiz-daemon.tar.gz -C /opt/ \
    && mv /opt/cloudwiz-daemon /opt/alertd \
    && rm /tmp/cloudwiz-daemon.tar.gz* \
    && ln -s /usr/lib/jvm/java  /opt/jdk

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5001
EXPOSE 7001
EXPOSE 9999

ENTRYPOINT ["/start.sh"]

