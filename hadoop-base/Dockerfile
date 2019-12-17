FROM cloudwiz/openjdk:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV HADOOP_VERSION  2.7.7
ENV HADOOP_URL ${PKG_URL:-http://download.cloudwiz.cn/package}/hadoop-$HADOOP_VERSION.tar.gz
ENV JAVA_HOME ${INSTALL_ROOT}/jdk

RUN apt-get -y update && apt-get install -y net-tools netcat perl \
    && apt-get clean all \
    && rm -rf /var/cache/ \

RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/hadoop.tar.gz -C ${INSTALL_ROOT} \
    && rm -rf /tmp/hadoop.tar.gz*

RUN ln -s ${INSTALL_ROOT}/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
RUN cp /etc/hadoop/mapred-site.xml.template /etc/hadoop/mapred-site.xml
RUN mkdir -p ${INSTALL_ROOT}/hadoop-$HADOOP_VERSION/logs

RUN mkdir /hadoop-data

ENV HADOOP_PREFIX=${INSTALL_ROOT}/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1

ENV USER=root
ENV PATH $HADOOP_PREFIX/bin/:$PATH

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
