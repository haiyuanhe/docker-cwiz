FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-permission.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/cloudwiz-permission.tar.gz \
    && tar -xvf /tmp/cloudwiz-permission.tar.gz -C /opt/ \
    && mv /opt/cloudwiz-permission /opt/permission \
    && rm /tmp/cloudwiz-permission.tar.gz* \
    && ln -s /usr/lib/jvm/java  /opt/jdk


ENV USER=root

EXPOSE 4123

CMD ["/opt/permission/bin/start.sh"]
