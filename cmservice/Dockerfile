FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-cm-service.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-cm-service.tar.gz \
    && tar -xvf /tmp/cloudwiz-cm-service.tar.gz -C /opt/ \
    && mv /opt/cloudwiz-cm-service /opt/cmservice \
    && mkdir -p /opt/cmservice/config \
    && rm /tmp/cloudwiz-cm-service.tar.gz* \
    && ln -s /usr/lib/jvm/java  /opt/jdk


ENV USER=root

EXPOSE 9601

CMD ["/opt/cmservice/bin/start.sh"]
