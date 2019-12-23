FROM cloudwiz/hadoop-base-kerberos:2.7.7
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

HEALTHCHECK CMD curl -f http://localhost:50070/ || exit 1

VOLUME /data/dfs/namenode

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 50070

CMD ["/run.sh"]
