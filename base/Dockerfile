FROM adoptopenjdk/openjdk8:x86_64-ubuntu-jdk8u232-b09-slim
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ADD wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}
RUN mkdir -p ${INSTALL_ROOT} && ln -s /opt/java/openjdk/ ${INSTALL_ROOT}/jdk