FROM cloudwiz/openjdk

MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV USER=root
ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}

RUN set -x \
    && yum install -y mariadb.x86_64 mariadb-libs.x86_64 \
    && curl -fSL "${URL}/supervisord.tar.gz" -o /tmp/supervisord.tar.gz \
    && tar -xvf /tmp/supervisord.tar.gz -C /opt/ \
    && rm /tmp/supervisord.tar.gz* \
    && curl -fSL "${URL}/agent.tar.gz" -o /tmp/agent.tar.gz \
    && tar -xvf /tmp/agent.tar.gz -C /opt/ \
    && rm /tmp/agent.tar.gz* \
    && curl -fSL "${URL}/kazoo-2.4.0.tar.gz" -o /tmp/kazoo-2.4.0.tar.gz \
    && tar -xvf /tmp/kazoo-2.4.0.tar.gz -C /opt/ \
    && mv /opt/kazoo-2.4.0 /opt/kazoo \
    && rm /tmp/kazoo-2.4.0.tar.gz* 

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
