DOCKER_NETWORK = hbase
ENV_FILE = hadoop.env
hbase_branch := 1.0.0-hbase1.2.6
hadoop_branch := 2.0.0-hadoop2.7.4-java8
build:
	docker build -t Cloudwiz/hadoop-base:$(hadoop_branch) ./hadoop-base
	docker build -t Cloudwiz/hbase-hbase:$(hbase_branch) ./hbase-base