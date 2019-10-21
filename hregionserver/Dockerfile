FROM cloudwiz/hbase-hbase
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

COPY run.sh /run.sh
COPY create_table.sh /create_table.sh

RUN chmod +x /create_table.sh
RUN chmod +x /run.sh

EXPOSE 16020 16030

CMD ["/run.sh"]
