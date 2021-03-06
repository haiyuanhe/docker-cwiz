#!/bin/bash
docker save --output nginx nginx
docker save --output cloudwiz_alertd cloudwiz/alertd
docker save --output cloudwiz_chartservice cloudwiz/chartservice
docker save --output cloudwiz_cmservice cloudwiz/cmservice
docker save --output cloudwiz_hadoop-datanode cloudwiz/hadoop-datanode
docker save --output cloudwiz_hadoop-namenode cloudwiz/hadoop-namenode
docker save --output cloudwiz_hbase-master cloudwiz/hbase-master
docker save --output cloudwiz_hbase-regionserver cloudwiz/hbase-regionserver
docker save --output cloudwiz_log-analysis cloudwiz/log-analysis
docker save --output cloudwiz_log-pp  cloudwiz/log-pp
docker save --output cloudwiz_log-processor cloudwiz/log-processor
docker save --output cloudwiz_metric-proxy  cloudwiz/metric-proxy
docker save --output cloudwiz_mysql  cloudwiz/mysql
docker save --output cloudwiz_opentsdb cloudwiz/opentsdb
docker save --output cloudwiz_permission  cloudwiz/permission
docker save --output cloudwiz_webfront  cloudwiz/webfront
docker save --output elasticsearch  elasticsearch
docker save --output wurstmeister_kafka wurstmeister/kafka
docker save --output zookeeper   zookeeper