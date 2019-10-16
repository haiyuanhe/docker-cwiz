FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-log-processor.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-log-processor.tar.gz \
    && tar -xvf /tmp/cloudwiz-log-processor.tar.gz -C /opt/ \
    && mv /opt/cloudwiz-log-processor /opt/log-processor \
    && mkdir -p /opt/log-processor/config \
    && rm /tmp/cloudwiz-log-processor.tar.gz* \
    && ln -s /usr/lib/jvm/java  /opt/jdk


ENV USER=root

#EXPOSE 9601

CMD ["/opt/log-processor/bin/start.sh"]
