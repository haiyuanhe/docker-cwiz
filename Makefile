DOCKER_NETWORK = hbase
ENV_FILE = hadoop.env
build:
        docker build -t cloudwiz/openjdk ./base
        docker build -t cloudwiz/hadoop-base ./hadoop-base
        docker build -t cloudwiz/hbase-hbase ./hbase-base
        docker build -t cloudwiz/hadoop-namenode ./namenode
        docker build -t cloudwiz/hadoop-datanode ./datanode
        docker build -t cloudwiz/hbase-master ./hmaster
        docker build -t cloudwiz/hbase-regionserver ./hregionserver
        docker build -t cloudwiz/metric-proxy ./metric-proxy
        docker build -t cloudwiz/opentsdb ./opentsdb