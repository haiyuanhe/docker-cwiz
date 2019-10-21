#!/bin/sh
# Small script to setup the HBase tables used by OpenTSDB.
HBASE_HOME=/opt/hbase-$HBASE_VERSION
NAME=hbase-master
PORT=16010

test -n "$HBASE_HOME" || {
  echo >&2 'The environment variable HBASE_HOME must be set'
  exit 1
}
test -d "$HBASE_HOME" || {
  echo >&2 "No such directory: HBASE_HOME=$HBASE_HOME"
  exit 1
}

# make sure HMaster is ready
echo "Waiting for HMaster to get ready"
_hmaster_hosts=( $NAME )
_ready=0
while [ 1 ]
do
    _done=0
    for _h in ${_hmaster_hosts[@]}
    do
        _hmaster_url="http://$_h:$PORT/master-status?format=json"
        _status=$(curl -s "$_hmaster_url")

        if [ "_${_status//[[:space:]]/}_" = "_[]_" ]; then
            _done=1
            break
        fi
    done

    if [ $_done -ne 0 ]; then
        _ready=$((_ready+1))
        echo "HMaster is getting ready"
        sleep 2
    else
        _ready=0
        echo "HMaster is not ready"
        sleep 10
    fi

    if [ $_ready -gt 8 ]; then
        echo "HMaster is ready"
        break
    fi
done


TSDB_TABLE=${TSDB_TABLE-'tsdb'}
UID_TABLE=${UID_TABLE-'tsdb-uid'}
TREE_TABLE=${TREE_TABLE-'tsdb-tree'}
META_TABLE=${META_TABLE-'tsdb-meta'}
BLOOMFILTER=${BLOOMFILTER-'ROW'}
ALERT_DEFINITION_META_TABLE='alert-definition'
ALERT_STATUS_TABLE='alert-status'
ALERT_HISTORY_TABLE='alert-history'
ALERT_NOTIFICATION_TABLE='alert-notification'
ONCALLER_TABLE='oncaller'
ONCALL_SCHEDULE_TABLE='oncall-schedule'
ORG_SERVICE_HEALTH_TABLE='org-service-health'
ORG_SERVICE_SUMMARY_TABLE='org-service-summary'
CORRELATION_DISTANCE_TABLE='correlation-distance'
CORRELATION_REQUEST_TABLE='correlation-request'
ANOMALY_HISTORY_TABLE='anomaly-history'
STATUS_TABLE='summary'
SERVICE_KPIS_TABLE='service-KPIs'
RC_FEEDBACKS_TABLE='RC-feedbacks'
HOST_PROCESSES='host-processes'
KUBERNETES='kubernetes'
AGENT_CHECK='agent-check'
REPORTING='reporting'
TAYLOR_DETECTOR_TABLE='taylor-detector'
LOG_FIND_TABLE='log-find'
LOG_TYPE_TABLE='log-type'
FILE_UPLOAD_TABLE='File-upload'
ALERT_REALTIME_MODEL='alert-realtime-model'
ALERT_RC='alert-rc'
ALERT_GROUP='alert-group'
ALERT_GROUP_HISTORY='alert-group-history'
TOPO_DATA='topo-data'

# LZO requires lzo2 64bit to be installed + the hadoop-gpl-compression jar.
COMPRESSION=${COMPRESSION-'GZ'}
# All compression codec names are upper case (NONE, LZO, SNAPPY, etc).
COMPRESSION=`echo "$COMPRESSION" | tr a-z A-Z`

case $COMPRESSION in
  (NONE|LZO|GZ|SNAPPY)  :;;  # Known good.
  (*)
    echo >&2 "warning: compression codec '$COMPRESSION' might not be supported."
    ;;
esac

# HBase scripts also use a variable named `HBASE_HOME', and having this
# variable in the environment with a value somewhat different from what
# they expect can confuse them in some cases.  So rename the variable.
hbh=$HBASE_HOME
unset HBASE_HOME

tables=$(echo 'list' | exec "$hbh/bin/hbase" shell)
while [[ $tables == *"TABLE ERROR: Can't get master address from ZooKeeper"* ]];
do
  echo "HBase is not ready! Please wait."
  tables=$(echo 'list' | exec "$hbh/bin/hbase" shell)
done

echo tables=$tables

echo "tables=> $tables    UID_TABLE=> ${UID_TABLE}"

if [[ $tables == *${UID_TABLE}* ]]; then
  echo "no need to recreate opentsdb tables."
  exit 0
fi

exec "$hbh/bin/hbase" shell <<EOF
create '$UID_TABLE',
  {NAME => 'id', COMPRESSION => '$COMPRESSION', BLOOMFILTER => '$BLOOMFILTER'},
  {NAME => 'name', COMPRESSION => '$COMPRESSION', BLOOMFILTER => '$BLOOMFILTER'}

create '$TSDB_TABLE',
  {NAME => 't', VERSIONS => 1, COMPRESSION => '$COMPRESSION', BLOOMFILTER => '$BLOOMFILTER'},
  {SPLITS => ['\x00\x0F\x00\x00\x00\x00\x00\x00', '\x01\x00\x00\x00\x00\x00\x00\x00', '\x01\x0F\x00\x00\x00\x00\x00\x00', '\x02\x00\x00\x00\x00\x00\x00\x00', '\x02\x0F\x00\x00\x00\x00\x00\x00', '\x03\x00\x00\x00\x00\x00\x00\x00', '\x03\x0F\x00\x00\x00\x00\x00\x00', '\x04\x00\x00\x00\x00\x00\x00\x00', '\x04\x0F\x00\x00\x00\x00\x00\x00', '\x05\x00\x00\x00\x00\x00\x00\x00', '\x05\x0F\x00\x00\x00\x00\x00\x00', '\x06\x00\x00\x00\x00\x00\x00\x00', '\x06\x0F\x00\x00\x00\x00\x00\x00', '\x07\x00\x00\x00\x00\x00\x00\x00', '\x07\x0F\x00\x00\x00\x00\x00\x00', '\x08\x00\x00\x00\x00\x00\x00\x00', '\x08\x0F\x00\x00\x00\x00\x00\x00', '\x09\x00\x00\x00\x00\x00\x00\x00', '\x09\x0F\x00\x00\x00\x00\x00\x00', '\x0A\x00\x00\x00\x00\x00\x00\x00', '\x0A\x0F\x00\x00\x00\x00\x00\x00', '\x0B\x00\x00\x00\x00\x00\x00\x00', '\x0B\x0F\x00\x00\x00\x00\x00\x00', '\x0C\x00\x00\x00\x00\x00\x00\x00', '\x0C\x0F\x00\x00\x00\x00\x00\x00', '\x0D\x00\x00\x00\x00\x00\x00\x00', '\x0D\x0F\x00\x00\x00\x00\x00\x00', '\x0E\x00\x00\x00\x00\x00\x00\x00', '\x0E\x0F\x00\x00\x00\x00\x00\x00', '\x0F\x00\x00\x00\x00\x00\x00\x00', '\x0F\x0F\x00\x00\x00\x00\x00\x00', '\x10\x00\x00\x00\x00\x00\x00\x00', '\x10\x0F\x00\x00\x00\x00\x00\x00', '\x11\x00\x00\x00\x00\x00\x00\x00', '\x11\x0F\x00\x00\x00\x00\x00\x00', '\x12\x00\x00\x00\x00\x00\x00\x00', '\x12\x0F\x00\x00\x00\x00\x00\x00', '\x13\x00\x00\x00\x00\x00\x00\x00', '\x13\x0F\x00\x00\x00\x00\x00\x00', '\x14\x00\x00\x00\x00\x00\x00\x00', '\x14\x0F\x00\x00\x00\x00\x00\x00', '\x15\x00\x00\x00\x00\x00\x00\x00', '\x15\x0F\x00\x00\x00\x00\x00\x00', '\x16\x00\x00\x00\x00\x00\x00\x00', '\x16\x0F\x00\x00\x00\x00\x00\x00', '\x17\x00\x00\x00\x00\x00\x00\x00', '\x17\x0F\x00\x00\x00\x00\x00\x00', '\x18\x00\x00\x00\x00\x00\x00\x00', '\x18\x0F\x00\x00\x00\x00\x00\x00', '\x19\x00\x00\x00\x00\x00\x00\x00', '\x19\x0F\x00\x00\x00\x00\x00\x00', '\x1A\x00\x00\x00\x00\x00\x00\x00', '\x1A\x0F\x00\x00\x00\x00\x00\x00', '\x1B\x00\x00\x00\x00\x00\x00\x00', '\x1B\x0F\x00\x00\x00\x00\x00\x00', '\x1C\x00\x00\x00\x00\x00\x00\x00', '\x1C\x0F\x00\x00\x00\x00\x00\x00', '\x1D\x00\x00\x00\x00\x00\x00\x00', '\x1D\x0F\x00\x00\x00\x00\x00\x00', '\x1E\x00\x00\x00\x00\x00\x00\x00', '\x1E\x0F\x00\x00\x00\x00\x00\x00', '\x1F\x00\x00\x00\x00\x00\x00\x00', '\x1F\x0F\x00\x00\x00\x00\x00\x00']},
  {METADATA => {'SPLIT_POLICY' => 'org.apache.hadoop.hbase.regionserver.ConstantSizeRegionSplitPolicy', 'MAX_FILESIZE' => '30000000000'}}

create '$TREE_TABLE',
  {NAME => 't', VERSIONS => 1, COMPRESSION => '$COMPRESSION', BLOOMFILTER => '$BLOOMFILTER'}

create '$META_TABLE',
  {NAME => 'name', COMPRESSION => '$COMPRESSION', BLOOMFILTER => '$BLOOMFILTER'}

create '$ALERT_DEFINITION_META_TABLE',
  {NAME => 'meta', COMPRESSION => '$COMPRESSION'}

create '$ALERT_STATUS_TABLE',
  {NAME => 'status', COMPRESSION => '$COMPRESSION'}

create '$ALERT_HISTORY_TABLE',
    {NAME => 'history', COMPRESSION => '$COMPRESSION'}

create '$ALERT_NOTIFICATION_TABLE',
    {NAME => 'notify', COMPRESSION => '$COMPRESSION'}

create '$ONCALLER_TABLE',
  {NAME => 'pri', COMPRESSION => '$COMPRESSION'}

create '$ONCALL_SCHEDULE_TABLE',
  {NAME => 'cf', COMPRESSION => '$COMPRESSION'}

create '$ORG_SERVICE_HEALTH_TABLE',
  {NAME => 'h', COMPRESSION => '$COMPRESSION'},
  {NAME => 'misc', COMPRESSION => '$COMPRESSION'}

create '$ORG_SERVICE_SUMMARY_TABLE',
  {NAME => 'mg', COMPRESSION => '$COMPRESSION'},
  {NAME => 'em', COMPRESSION => '$COMPRESSION'},
  {NAME => 'misc', COMPRESSION => '$COMPRESSION'}

create '$CORRELATION_DISTANCE_TABLE',
  {NAME => 'd', COMPRESSION => '$COMPRESSION'},
  {NAME => 'misc', COMPRESSION => '$COMPRESSION'}

create '$CORRELATION_REQUEST_TABLE',
  {NAME => 'cf', COMPRESSION => '$COMPRESSION'},
  {NAME => 'misc', COMPRESSION => '$COMPRESSION'}

create '$STATUS_TABLE',
  {NAME => 'tag', COMPRESSION => '$COMPRESSION'},
  {NAME => 'content', COMPRESSION => '$COMPRESSION'}

create '$ANOMALY_HISTORY_TABLE',
  {NAME => 'anomaly', COMPRESSION => '$COMPRESSION'},
  {NAME => 'misc', COMPRESSION => '$COMPRESSION'}

create '$SERVICE_KPIS_TABLE',
  {NAME => 'setting', COMPRESSION => '$COMPRESSION'},
  {NAME => 'misc', COMPRESSION => '$COMPRESSION'}

create '$RC_FEEDBACKS_TABLE',
  {NAME => 'cf', COMPRESSION => '$COMPRESSION'},
  {NAME => 'misc', COMPRESSION => '$COMPRESSION'}

create '$HOST_PROCESSES',
  {NAME => 'h', COMPRESSION => '$COMPRESSION'},
  {METADATA => {'SPLIT_POLICY' => 'org.apache.hadoop.hbase.regionserver.ConstantSizeRegionSplitPolicy', 'MAX_FILESIZE' => '30000000000'}}

create '$KUBERNETES',
  {NAME => 'k8s', COMPRESSION => '$COMPRESSION'},
  {METADATA => {'SPLIT_POLICY' => 'org.apache.hadoop.hbase.regionserver.ConstantSizeRegionSplitPolicy', 'MAX_FILESIZE' => '30000000000'}}

create '$AGENT_CHECK',
  {NAME => 'a', COMPRESSION => '$COMPRESSION'}

create '$REPORTING',
  {NAME => 'r', COMPRESSION => '$COMPRESSION'}

create '$TAYLOR_DETECTOR_TABLE',
  {NAME => 'cf', COMPRESSION => '$COMPRESSION'}

create '$LOG_FIND_TABLE',
  {NAME => 'f', COMPRESSION => '$COMPRESSION'}

create '$LOG_TYPE_TABLE',
  {NAME => 't', COMPRESSION => '$COMPRESSION'}

create '$FILE_UPLOAD_TABLE',
  {NAME => 'f', COMPRESSION => '$COMPRESSION'}

create '$ALERT_REALTIME_MODEL',
  {NAME => 'cf', TTL => '2851200', COMPRESSION => '$COMPRESSION'}

create '$ALERT_RC',
  {NAME => 'rc', COMPRESSION => '$COMPRESSION'}

create '$ALERT_GROUP',
  {NAME => 'gr', COMPRESSION => '$COMPRESSION'}

create '$ALERT_GROUP_HISTORY',
  {NAME => 'hs', COMPRESSION => '$COMPRESSION'}

create '$TOPO_DATA',
  {NAME => 'cf', COMPRESSION => '$COMPRESSION'}
EOF
