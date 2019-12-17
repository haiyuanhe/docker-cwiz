From ubuntu:latest
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}
ADD wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

ENV NODE_URL ${PKG_URL:-http://download.cloudwiz.cn/package}/node-v10.0.0-linux-x64.tgz
ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-user.tar.gz

RUN apt-get -y update && apt-get install -y curl && apt-get clean all
RUN set -x \
    && curl -fSL "$NODE_URL" -o /tmp/node-v10.0.0-linux-x64.tgz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/node-v10.0.0-linux-x64.tgz -C ${INSTALL_ROOT} \
    && rm /tmp/node-v10.0.0-linux-x64.tgz* \
    && mv ${INSTALL_ROOT}/node-v10.0.0-linux-x64 ${INSTALL_ROOT}/node \

    && curl -fSL "$URL" -o /tmp/cloudwiz-user.tar.gz \
    && tar -xvf /tmp/cloudwiz-user.tar.gz -C ${INSTALL_ROOT} \
    && rm /tmp/cloudwiz-user.tar.gz* 

ENV USER=root
ENV NODE_ENV=production

EXPOSE 7002

CMD ${INSTALL_ROOT}/node/bin/node ${INSTALL_ROOT}/cloudwiz-user/server.js
