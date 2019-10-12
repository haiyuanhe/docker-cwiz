FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ENV OPENTSDB_URL http://192.168.1.206:8080/package/cloudwiz-metric-proxy.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$HBASE_URL" -o /tmp/cloudwiz-metric-proxy.tar.gz \
    && tar -xvf /tmp/cloudwiz-metric-proxy.tar.gz -C /opt/ \
    && mkdir -p /opt/cloudwiz-metric-proxy/config \
    && rm /tmp/cloudwiz-metric-proxy.tar.gz*


ENV USER=root

EXPOSE 4243

CMD ["/opt/cloudwiz-metric-proxy/bin/start.sh"]
