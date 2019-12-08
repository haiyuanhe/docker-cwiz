#!/usr/bin/env bash
#master
docker run --privileged --add-host 172.17.0.2:master -itd -p 20022:22 -p 8000:8000 -p 14505:4505 -p 14506:45406 centos:salt-master /usr/sbin/init
#minion
docker run --privileged --add-host 172.17.0.3:minion1 -itd -p 20023:22 centos:salt-minion /usr/sbin/init