FROM cloudwiz/hbase-base
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 16000 16010

CMD ["/run.sh"]
