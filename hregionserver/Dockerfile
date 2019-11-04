FROM cloudwiz/hbase-base
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

COPY health_check.sh /health_check.sh
RUN chmod +x /health_check.sh
HEALTHCHECK --interval=4s --timeout=10s --retries=100 CMD /health_check.sh

COPY run.sh /run.sh
COPY create_table.sh /create_table.sh

RUN chmod +x /run.sh
RUN chmod +x /create_table.sh

EXPOSE 16020 16030

CMD ["/run.sh"]
