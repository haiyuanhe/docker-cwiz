FROM centos:6.6

MAINTAINER Yongtao You <yongtao.you@cloudwiz.cn>

# Install necessary packages
RUN yum install -y epel-release

RUN yum update -y

RUN yum install -y salt-master

RUN yum install -y salt-api

# Clone tcollector repo from github.com
RUN mkdir -p /root/src
WORKDIR /root/src