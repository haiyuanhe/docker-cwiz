DOCKER_NETWORK = hbase
ENV_FILE = hadoop.env
PKG_URL=188.66.20.39:8989
INSTALL_ROOT=/opt
build:
	docker build -t cloudwiz/openjdk ./base
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hadoop-base ./hadoop-base
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hbase-hbase ./hbase-base
	docker build --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hadoop-namenode ./namenode
	docker build --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hadoop-datanode ./datanode
	docker build --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hbase-master ./hmaster
	docker build --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/hbase-regionserver ./hregionserver
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/metric-proxy ./metric-proxy
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/opentsdb ./opentsdb
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/cmservice ./cmservice
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/log-processor ./log-processor
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/webfront ./webfront
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/permission ./permission
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/cloudwiz-user ./cloudwiz-user
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/log-analysis ./log-analysis
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/chartservice ./chartservice
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/log-pp ./log-pp
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/alertd ./alertd
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/oneagent ./oneagent
	docker build --build-arg PKG_URL=${PKG_URL} --build-arg INSTALL_ROOT=${INSTALL_ROOT} -t cloudwiz/umanager ./umanager
	docker build -t cloudwiz/mysql ./mysql
