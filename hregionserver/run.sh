#!/bin/bash

set -m
${INSTALL_ROOT}/hbase-$HBASE_VERSION/bin/hbase regionserver start &
/create_table.sh
fg
