#!/bin/bash

export JAVA_HOME=<:java_home:>
export JAR_FILE=<:install_root:>/jmxtrans/lib/jmxtrans-all.jar
export LOG_DIR=<:log_root:>/jmxtrans
export SECONDS_BETWEEN_RUNS=60
export HEAP_SIZE=128
export LOG_LEVEL=info

<:install_root:>/jmxtrans/bin/jmxtrans.sh run <:install_root:>/jmxtrans/config/config.json

exit 0
