DOCKER_NETWORK = hbase
ENV_FILE = hadoop.env
build:
	docker build -t cloudwiz/hadoop-base ./hadoop-base
	docker build -t cloudwiz/hbase-hbase ./hbase-base
	docker build -t cloudwiz/hadoop-namenode ./namenode
    docker build -t cloudwiz/hadoop-datanode ./datanode