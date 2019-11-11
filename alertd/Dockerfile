FROM cloudwiz/openjdk:1.0.0
MAINTAINER haiyuan he <haiyuan.he@cloudwiz.cn>

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}
ENV JAVA_HOME /usr/lib/jvm/java
ENV USER=root

RUN set -x \
    && curl -fSL "$URL/cloudwiz-daemon.tar.gz" -o /tmp/cloudwiz-daemon.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/cloudwiz-daemon.tar.gz -C ${INSTALL_ROOT} \
    && mv ${INSTALL_ROOT}/cloudwiz-daemon ${INSTALL_ROOT}/alertd \
    && rm /tmp/cloudwiz-daemon.tar.gz* \

ADD start.sh /start.sh
RUN chmod +x /start.sh

# for chartservice
RUN mkdir -p /usr/share/fonts/yahei/
ADD msyh.ttf /usr/share/fonts/yahei/msyh.ttf

RUN set -x \
    && chmod +x /usr/share/fonts/yahei/msyh.ttf \
    && cd /usr/share/fonts/yahei/ \
    && mkfontscale \
    && mkfontdir \
    && fc-cache -fv \
    && yum -y install libXrender libXext fontconfig \
    && curl -fSL "$URL/phantomjs-2.1.1-linux-x86_64.tar.gz" -o /tmp/phantomjs-2.1.1-linux-x86_64.tar.gz \
    && tar -xvf /tmp/phantomjs-2.1.1-linux-x86_64.tar.gz -C ${INSTALL_ROOT}/ \
    && mv ${INSTALL_ROOT}/phantomjs-2.1.1-linux-x86_64 ${INSTALL_ROOT}/phantomjs \
    && rm /tmp/phantomjs-2.1.1-linux-x86_64.tar.gz* \
    && curl -fSL "$URL/wkhtmltox-0.12.4_linux-generic-amd64.tar.gz" -o /tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.gz \
    && tar -xvf /tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.gz -C ${INSTALL_ROOT} \
    && rm /tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.gz* \
    && curl -fSL "$URL/pandoc-2.0.5-linux.tar.gz" -o /tmp/pandoc-2.0.5-linux.tar.gz \
    && tar -xvf /tmp/pandoc-2.0.5-linux.tar.gz -C ${INSTALL_ROOT} \
    && mv ${INSTALL_ROOT}/pandoc-2.0.5 ${INSTALL_ROOT}/pandoc \
    && rm /tmp/pandoc-2.0.5-linux.tar.gz* \
    && mkdir -p ${INSTALL_ROOT}/report_tmp/

EXPOSE 5001
EXPOSE 7001
EXPOSE 9999

ENTRYPOINT /start.sh

