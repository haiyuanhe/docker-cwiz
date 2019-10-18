DOCKER_NETWORK = hbase
ENV_FILE = hadoop.env
PKG_URL=http://download.cloudwiz.cn/package
build:
	docker build -t cloudwiz/openjdk ./base
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/hadoop-base ./hadoop-base
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/hbase-hbase ./hbase-base
	docker build -t cloudwiz/hadoop-namenode ./namenode
	docker build -t cloudwiz/hadoop-datanode ./datanode
	docker build -t cloudwiz/hbase-master ./hmaster
	docker build -t cloudwiz/hbase-regionserver ./hregionserver
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/metric-proxy ./metric-proxy
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/opentsdb ./opentsdb
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/cmservice ./cmservice
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/log-processor ./log-processor
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/webfront ./webfront
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/permission ./permission
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/cloudwiz-user ./cloudwiz-user
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/log-analysis ./log-analysis
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/chartservice ./chartservice
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/log-pp ./log-pp
	docker build --build-arg PKG_URL=${PKG_URL} -t cloudwiz/alertd ./alertd
	docker build -t cloudwiz/mysql ./mysql
