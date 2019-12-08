#!/bin/bash

. <:install_root:>/startup/envs.sh

function kill_child_process {
    CHILD_PID=$(pgrep -P $$)
    kill $CHILD_PID
}

trap kill_child_process EXIT

# make sure hbase tabel 'tsdb' exists

echo -e "exists 'tsdb'" | <:install_root:>/hbase/bin/hbase shell 2>&1 | grep -q "does not exist"
if [ $? -eq 0 ]; then
    echo "Hbase is not ready, will not start opentsdb."
    exit 1
fi

OPENTSDB_HOME=<:install_root:>/opentsdb

<:java_home:>/bin/java -Xms$OPENTSDB_HEAP_SIZE_MIN -Xmx$OPENTSDB_HEAP_SIZE_MAX -XX:OnOutOfMemoryError="kill -9 %p" -enableassertions -enablesystemassertions -classpath $OPENTSDB_HOME/*.jar:$OPENTSDB_HOME:$OPENTSDB_HOME/bin:$OPENTSDB_HOME/lib/async-1.4.0.jar:$OPENTSDB_HOME/lib/asynchbase-1.7.2.jar:$OPENTSDB_HOME/lib/commons-jexl-2.1.1.jar:$OPENTSDB_HOME/lib/commons-logging-1.1.1.jar:$OPENTSDB_HOME/lib/commons-math3-3.4.1.jar:$OPENTSDB_HOME/lib/guava-18.0.jar:$OPENTSDB_HOME/lib/jackson-annotations-2.4.3.jar:$OPENTSDB_HOME/lib/jackson-core-2.4.3.jar:$OPENTSDB_HOME/lib/jackson-databind-2.4.3.jar:$OPENTSDB_HOME/lib/javacc-6.1.2.jar:$OPENTSDB_HOME/lib/jgrapht-core-0.9.1.jar:$OPENTSDB_HOME/lib/log4j-over-slf4j-1.7.7.jar:$OPENTSDB_HOME/lib/logback-classic-1.0.13.jar:$OPENTSDB_HOME/lib/logback-core-1.0.13.jar:$OPENTSDB_HOME/lib/mysql-connector-java-5.1.39.jar:$OPENTSDB_HOME/lib/netty-3.9.4.Final.jar:$OPENTSDB_HOME/lib/protobuf-java-2.5.0.jar:$OPENTSDB_HOME/lib/slf4j-api-1.7.7.jar:$OPENTSDB_HOME/lib/tsdb-2.3.0.jar:$OPENTSDB_HOME/lib/zookeeper-3.4.6.jar:$OPENTSDB_HOME/conf  net.opentsdb.tools.TSDMain --port=4242 --staticroot=$OPENTSDB_HOME/static --cachedir=$OPENTSDB_HOME/opentsdb/cache --config=$OPENTSDB_HOME/conf/opentsdb.conf

exit 0
