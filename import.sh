#!/bin/bash
docker load --input centos
docker load --input cloudwiz_openjdk
docker load --input mysql
docker load --input nginx
docker load --input cloudwiz_alertd
docker load --input cloudwiz_chartservice
docker load --input cloudwiz_cmservice
docker load --input cloudwiz_hadoop-base
docker load --input cloudwiz_hadoop-datanode
docker load --input cloudwiz_hadoop-namenode
docker load --input cloudwiz_hbase-base
docker load --input cloudwiz_hbase-master
docker load --input cloudwiz_hbase-regionserver
docker load --input cloudwiz_log-analysis
docker load --input cloudwiz_log-pp
docker load --input cloudwiz_log-processor
docker load --input cloudwiz_metric-proxy
docker load --input cloudwiz_mysql
docker load --input cloudwiz_opentsdb
docker load --input cloudwiz_permission
docker load --input cloudwiz_webfront
docker load --input elasticsearch
docker load --input wurstmeister_kafka
docker load --input zookeeper