From ubuntu:latest
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}
ADD wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}/webfront.tar.gz
ENV USER=root

RUN apt-get -y update && apt-get install -y curl && apt-get clean all
RUN set -x \
    && curl -fSL "$URL" -o /tmp/webfront.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/webfront.tar.gz -C ${INSTALL_ROOT} \
    && rm /tmp/webfront.tar.gz* \
    && mkdir /public

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000

ENTRYPOINT /wait-for-it.sh permission:4123 --timeout=5 -- /start.sh
