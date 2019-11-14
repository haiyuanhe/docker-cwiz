FROM centos:7

MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}
ENV JAVA_HOME /usr/lib/jvm/java
ADD wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/OpenJDK8U-jdk_x64_linux_hotspot_8u232b09.tar.gz

RUN yum-config-manager --enable cr && \
    yum -y --setopt=tsflags=nodocs update && \
    yum -y install net-tools curl netcat which perl nc && \
    yum -y clean all && \
    rm -rf /var/cache/yum

RUN set -x && \
    curl -fSL "$URL" -o /tmp/java.tar.gz && \
    mkdir -p ${INSTALL_ROOT} && \
    tar -xvf /tmp/java.tar.gz -C ${INSTALL_ROOT} && \
    mv ${INSTALL_ROOT}/jdk8*  ${INSTALL_ROOT}/jdk && \
    rm -rf /tmp/*