FROM centos

MAINTAINER Yongtao You <yongtao.you@cloudwiz.cn>

# Install Salt Repo
RUN yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm

# Install necessary packages
RUN yum install -y epel-release

RUN yum update -y

RUN yum install -y salt-master

RUN yum install -y salt-api pyOpenSSL

RUN yum install -y wget

RUN wget https://bootstrap.pypa.io/get-pip.py

RUN python get-pip.py

RUN pip install ws4py

RUN echo "default_include: master.d/*.conf" >> /etc/salt/master

RUN echo "transport: tcp" >> /etc/salt/master

RUN mkdir -p /etc/salt/master.d

COPY api.conf /etc/salt/master.d/

RUN useradd -M -s /sbin/nologin saltapi

RUN echo 'saltapi' | passwd saltapi --stdin

# Clone tcollector repo from github.com
RUN mkdir -p /root/src
WORKDIR /root/src

CMD systemctl start salt-master
CMD systemctl start salt-api
