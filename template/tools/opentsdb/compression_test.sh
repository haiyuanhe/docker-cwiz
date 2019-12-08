#!/bin/bash

export JAVA_HOME="<:java_home:>"
export HADOOP_HOME="<:install_root:>/hadoop"
export HBASE_HOME="<:install_root:>/hbase"

export LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64/server:<:install_root:>/hadoop/lib/native

echo "hello" > /tmp/hello.txt

cd $HBASE_HOME
./bin/hbase org.apache.hadoop.hbase.util.CompressionTest file:///tmp/hello.txt lzo
