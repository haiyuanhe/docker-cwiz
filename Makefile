DOCKER_NETWORK = hbase
ENV_FILE = hadoop.env
hbase_branch := hbase1.2.6
hadoop_branch := hadoop2.7.4
build:
	docker build -t Cloudwiz/hadoop-base:$(hadoop_branch) ./hadoop-base
	docker build -t Cloudwiz/hbase-hbase:$(hbase_branch) ./hbase-base