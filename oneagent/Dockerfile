FROM cloudwiz/openjdk
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/oneagent.tar.gz
ENV JAVA_HOME /usr/lib/jvm/java

RUN set -x \
    && curl -fSL "$URL" -o /tmp/oneagent.tar.gz \
    && tar -xvf /tmp/oneagent.tar.gz -C /opt/ \
    && rm /tmp/oneagent.tar.gz* \
    && ln -s /usr/lib/jvm/java  /opt/jdk


ENV USER=root

EXPOSE 8888

CMD ["/opt/oneagent/bin/start.sh"]
