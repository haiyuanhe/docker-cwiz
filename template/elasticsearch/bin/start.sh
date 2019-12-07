#!/bin/sh
#
# /etc/init.d/elasticsearch -- startup script for Elasticsearch
#
# Written by Miquel van Smoorenburg <miquels@cistron.nl>.
# Modified for Debian GNU/Linux by Ian Murdock <imurdock@gnu.ai.mit.edu>.
# Modified for Tomcat by Stefan Gybas <sgybas@debian.org>.
# Modified for Tomcat6 by Thierry Carrez <thierry.carrez@ubuntu.com>.
# Additional improvements by Jason Brittain <jason.brittain@mulesoft.com>.
# Modified by Nicolas Huray for Elasticsearch <nicolas.huray@gmail.com>.
#
### BEGIN INIT INFO
# Provides:          elasticsearch
# Required-Start:    $network $remote_fs $named
# Required-Stop:     $network $remote_fs $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts elasticsearch
# Description:       Starts elasticsearch using start-stop-daemon
### END INIT INFO

PATH=/bin:/usr/bin:/sbin:/usr/sbin
NAME=elasticsearch
DESC="Elasticsearch Server"

#if [ `id -u` -ne 0 ]; then
#    echo "You need root privileges to run this script"
#    exit 1
#fi


if [ -r /lib/lsb/init-functions ]; then
    . /lib/lsb/init-functions
fi

if [ -r /etc/default/rcS ]; then
    . /etc/default/rcS
fi

. <:install_root:>/startup/envs.sh


# The following variables can be overwritten in $DEFAULT

# Run Elasticsearch as this user ID and group ID
ES_USER=$USER
ES_GROUP=$USER

# Directory where the Elasticsearch binary distribution resides
ES_HOME=<:install_root:>/$NAME

# Heap size defaults to 256m min, 1g max
# Set ES_HEAP_SIZE to 50% of available RAM, but no more than 31g
ES_HEAP_SIZE=$ELASTICSEARCH_HEAP_SIZE_MAX

# Additional Java OPTS
ES_JAVA_OPTS="-Dorg.jboss.netty.epollBugWorkaround=true -Xms$ELASTICSEARCH_HEAP_SIZE_MAX -Xmx$ELASTICSEARCH_HEAP_SIZE_MAX"

# Heap new generation
#ES_HEAP_NEWSIZE=

# max direct memory
#ES_DIRECT_SIZE=

# Maximum number of open files
MAX_OPEN_FILES=65536

# Maximum amount of locked memory
#MAX_LOCKED_MEMORY=

# Elasticsearch log directory
LOG_DIR=<:log_root:>/$NAME

# Elasticsearch data directory
DATA_DIR=<:install_root:>/$NAME/data

# Elasticsearch configuration directory
#CONF_DIR=/etc/$NAME

# Maximum number of VMA (Virtual Memory Areas) a process can own
MAX_MAP_COUNT=262144

# Path to the GC log file
ES_GC_LOG_FILE=<:log_root:>/$NAME/gc.log

# Elasticsearch PID file directory
PID_DIR="<:install_root:>/$NAME"

# End of variables that can be overwritten in $DEFAULT

# overwrite settings from default file
if [ -f "$DEFAULT" ]; then
    . "$DEFAULT"
fi

# CONF_FILE setting was removed
if [ ! -z "$CONF_FILE" ]; then
    echo "CONF_FILE setting is no longer supported. elasticsearch.yml must be placed in the config directory and cannot be renamed."
    exit 1
fi

# Define other required variables
PID_FILE="$PID_DIR/$NAME.pid"
PROGRAM=$ES_HOME/bin/elasticsearch
PROGRAM_OPTS="-p $PID_FILE"

#export ES_HEAP_SIZE
#export ES_HEAP_NEWSIZE
#export ES_DIRECT_SIZE
export ES_JAVA_OPTS
#export ES_GC_LOG_FILE
export JAVA_HOME=<:java_home:>
export ES_INCLUDE

# Check DAEMON exists
test -x $DAEMON || exit 0

checkJava() {
    if [ -x "$JAVA_HOME/bin/java" ]; then
        JAVA="$JAVA_HOME/bin/java"
    else
        JAVA=`which java`
    fi

    if [ ! -x "$JAVA" ]; then
        echo "Could not find any executable java binary. Please install java in your PATH or set JAVA_HOME"
        exit 1
    fi
}

checkJava

if [ -n "$MAX_LOCKED_MEMORY" -a -z "$ES_HEAP_SIZE" ]; then
    log_failure_msg "MAX_LOCKED_MEMORY is set - ES_HEAP_SIZE must also be set"
    exit 1
fi

#log_daemon_msg "Starting $DESC"

pid=`pidofproc -p $PID_FILE elasticsearch`
if [ -n "$pid" ] ; then
    #log_begin_msg "Already running."
    #log_end_msg 0
    exit 0
fi

# Prepare environment
mkdir -p "$LOG_DIR" "$DATA_DIR" && chown "$ES_USER":"$ES_GROUP" "$LOG_DIR" "$DATA_DIR"

# Ensure that the PID_DIR exists (it is cleaned at OS startup time)
if [ -n "$PID_DIR" ] && [ ! -e "$PID_DIR" ]; then
    mkdir -p "$PID_DIR" && chown "$ES_USER":"$ES_GROUP" "$PID_DIR"
fi
if [ -n "$PID_FILE" ] && [ ! -e "$PID_FILE" ]; then
    touch "$PID_FILE" && chown "$ES_USER":"$ES_GROUP" "$PID_FILE"
fi

#if [ -n "$MAX_OPEN_FILES" ]; then
#    ulimit -n $MAX_OPEN_FILES
#fi

#if [ -n "$MAX_LOCKED_MEMORY" ]; then
#    ulimit -l $MAX_LOCKED_MEMORY
#fi

#if [ -n "$MAX_MAP_COUNT" -a -f /proc/sys/vm/max_map_count ]; then
#    sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT
#fi

function kill_child_process {
    CHILD_PID=$(pgrep -P $$)
    kill $CHILD_PID
}

trap kill_child_process EXIT

# Start the program
#start-stop-daemon -d $ES_HOME --start -b --user "$ES_USER" -c "$ES_USER" --pidfile "$PID_FILE" --exec $DAEMON -- $DAEMON_OPTS
#runuser -m $ES_USER -s /bin/bash -c "$PROGRAM $PROGRAM_OPTS"
/bin/bash -c "$PROGRAM $PROGRAM_OPTS"
exit $?
