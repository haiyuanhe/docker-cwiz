FROM centos:7
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL

ENV NODE_URL ${PKG_URL:-http://download.cloudwiz.cn/package}/node-v10.0.0-linux-x64.tgz
ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/cloudwiz-user.tar.gz

RUN set -x \
    && curl -fSL "$NODE_URL" -o /tmp/node-v10.0.0-linux-x64.tgz \
    && tar -xvf /tmp/node-v10.0.0-linux-x64.tgz -C /opt/ \
    && rm /tmp/node-v10.0.0-linux-x64.tgz* \
    && mv /opt/node-v10.0.0-linux-x64 /opt/node \

    && curl -fSL "$URL" -o /tmp/cloudwiz-user.tar.gz \
    && tar -xvf /tmp/cloudwiz-user.tar.gz -C /opt/ \
    && rm /tmp/cloudwiz-user.tar.gz* 

ENV USER=root
ENV NODE_ENV=production

EXPOSE 7002

CMD ["/opt/node/bin/node","/opt/cloudwiz-user/server.js"]
