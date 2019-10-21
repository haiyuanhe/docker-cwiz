#!/bin/bash

set -m
/opt/hbase-$HBASE_VERSION/bin/hbase regionserver start &
/create_table.sh
fg
