FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-chart-service.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-chart-service.tar.gz \
    && tar -xvf /tmp/cloudwiz-chart-service.tar.gz -C /opt/ \
    && mv /opt/cloudwiz-chart-service /opt/chartservice \
    && rm /tmp/cloudwiz-chart-service.tar.gz* \
    && ln -s /usr/lib/jvm/java  /opt/jdk \
    && mkdir -p /opt/report_tmp/


ENV USER=root

EXPOSE 5012

CMD ["/opt/chartservice/bin/start.sh"]
