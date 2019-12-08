FROM centos:latest

MAINTAINER Yongtao You <yongtao.you@cloudwiz.cn>

# Install Salt Repo
RUN yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm

# Install necessary packages
RUN yum install -y epel-release

RUN yum update -y

RUN yum install -y net-tools

RUN yum install -y salt-minion

RUN echo "master: master" >> /etc/salt/minion

RUN echo "id: client2" >> /etc/salt/minion

# Clone tcollector repo from github.com
RUN mkdir -p /root/src

WORKDIR /root/src

CMD ["systemctl","start","salt-minion"]
