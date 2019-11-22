FROM python:3.6

ARG PKG_URL
ARG INSTALL_ROOT
ENV INSTALL_ROOT ${INSTALL_ROOT}

ENV URL ${PKG_URL:-http://download.cloudwiz.cn/package}
ENV USER=root

RUN set -x \
    && curl -fSL "$URL/cloudwiz-pythond.tar.gz" -o /tmp/cloudwiz-pythond.tar.gz \
    && mkdir -p ${INSTALL_ROOT} \
    && tar -xvf /tmp/cloudwiz-pythond.tar.gz -C ${INSTALL_ROOT} \
    && rm /tmp/cloudwiz-pythond.tar.gz*

RUN pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple gunicorn && pip install --no-cache-dir -r ${INSTALL_ROOT}/pythond/requirement.txt -i https://pypi.tuna.tsinghua.edu.cn/simple && mkdir -p /log/python-daemon/

WORKDIR ${INSTALL_ROOT}/pythond

