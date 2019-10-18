FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-log-pp.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-log-pp.tar.gz \
    && tar -xvf /tmp/cloudwiz-log-pp.tar.gz -C /opt/ \
    && mv /opt/cloudwiz-log-pp /opt/log-pp \
    && rm /tmp/cloudwiz-log-pp.tar.gz* \
    && ln -s /usr/lib/jvm/java  /opt/jdk


ENV USER=root

EXPOSE 5045

CMD ["/opt/log-pp/bin/start.sh"]
