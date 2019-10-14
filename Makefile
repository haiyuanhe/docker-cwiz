DOCKER_NETWORK = hbase
ENV_FILE = hadoop.env
PKG_URL=http://192.168.1.206:8080/package
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
	docker build -t cloudwiz/mysql ./mysql
