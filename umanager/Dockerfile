FROM cloudwiz/openjdk:1.0.0

MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV USER=root
ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}

RUN set -x \
    && yum install -y mariadb.x86_64 mariadb-libs.x86_64 \
    && curl -fSL "${URL}/supervisord.tar.gz" -o /tmp/supervisord.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/supervisord.tar.gz -C ${INSTALL_ROOT} \
    && rm /tmp/supervisord.tar.gz* \
    && curl -fSL "${URL}/agent.tar.gz" -o /tmp/agent.tar.gz \
    && tar -xvf /tmp/agent.tar.gz -C ${INSTALL_ROOT} \
    && rm /tmp/agent.tar.gz* \
    && curl -fSL "${URL}/kazoo-2.4.0.tar.gz" -o /tmp/kazoo-2.4.0.tar.gz \
    && tar -xvf /tmp/kazoo-2.4.0.tar.gz -C ${INSTALL_ROOT} \
    && mv ${INSTALL_ROOT}/kazoo-2.4.0 ${INSTALL_ROOT}/kazoo \
    && rm /tmp/kazoo-2.4.0.tar.gz* 

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/wait-for-it.sh","alertd:5001","--timeout=10","--","/start.sh"]
