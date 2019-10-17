FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-log-analysis.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-log-analysis.tar.gz \
    && tar -xvf /tmp/cloudwiz-log-analysis.tar.gz -C /opt/ \
    && mv /opt/cloudwiz-log-analysis /opt/log-analysis \
    && rm /tmp/cloudwiz-log-analysis.tar.gz* \
    && ln -s /usr/lib/jvm/java  /opt/jdk


ENV USER=root

EXPOSE 9400

CMD ["/opt/log-analysis/bin/start.sh"]
