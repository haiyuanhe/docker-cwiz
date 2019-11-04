DOCKER_NETWORK = hbase
ENV_FILE = hadoop.env
PKG_URL=188.66.20.39:8989
INSTALL_ROOT=/opt/cwiz

OPENJDK=1.0.0
HADOOP_BASE=1.0.0
HBASE_BASE=1.0.0
HADOOP=2.7.7
HBASE=1.4.10
METRIC_PROXY=1.0.4
OPENTSDB=2.3.0
CMSERVICE=1.4.2
LOG_PROCESSOR=1.0.1
WEBFRONT=3.5.10
PERMISSION=1.0.10
CWIZ_USER=1.1.7
LOG_ANALYSIS=1.0.3
CHARTSERVICE=1.0.0
LOG_PP=1.0.1
CWIZ_DAEMON=1.1.13
UMANGER=1.0.0
MYSQL=5.7.24

build:
	docker build -t cloudwiz/openjdk:${OPENJDK} ./base
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hadoop-base:${HADOOP_BASE} ./hadoop-base
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hbase-base:${HBASE_BASE} ./hbase-base
	docker build --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hadoop-namenode:${HADOOP} ./namenode
	docker build --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hadoop-datanode:${HADOOP} ./datanode
	docker build --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hbase-master:${HBASE} ./hmaster
	docker build --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hbase-regionserver:${HBASE} ./hregionserver
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/metric-proxy:${METRIC_PROXY} ./metric-proxy
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/opentsdb:${OPENTSDB} ./opentsdb
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/cmservice:${CMSERVICE} ./cmservice
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/log-processor:${LOG_PROCESSOR} ./log-processor
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/webfront:${WEBFRONT} ./webfront
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/permission:${PERMISSION} ./permission
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/cloudwiz-user:${CWIZ_USER} ./cloudwiz-user
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/log-analysis:${LOG_ANALYSIS} ./log-analysis
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/chartservice:${CHARTSERVICE} ./chartservice
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/log-pp:${LOG_PP} ./log-pp
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/alertd:${CWIZ_DAEMON} ./alertd
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/umanager:${UMANGER} ./umanager
	docker build -t cloudwiz/mysql:${MYSQL} ./mysql
