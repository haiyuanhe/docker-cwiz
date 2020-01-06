FROM cloudwiz/hadoop-base:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

HEALTHCHECK CMD curl -f http://localhost:50075/ || exit 1

VOLUME /data/dfs/datanode

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 50075

CMD ["/run.sh"]
