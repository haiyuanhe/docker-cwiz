FROM cloudwiz/hadoop-base:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

HEALTHCHECK CMD curl -f http://localhost:50075/ || exit 1

ENV HDFS_CONF_dfs_datanode_data_dir=file:///hadoop/dfs/data
RUN mkdir -p /hadoop/dfs/data
VOLUME /hadoop/dfs/data

ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 50075

CMD ["/run.sh"]
