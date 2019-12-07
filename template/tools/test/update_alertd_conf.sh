#!/bin/bash
# This script is for automated testing script only.

export TERM=xterm-256color

INSTALL_ROOT=<:install_root:>

# update AlertD membership config to speed up the test
sed -i 's/cluster.reg.max.starting.millisecond.*/cluster.reg.max.starting.millisecond = 30000/' $INSTALL_ROOT/alertd/conf/cloudmon.alerting.conf
sed -i 's/cluster.reg.delay.notify.millisecond.*/cluster.reg.delay.notify.millisecond = 1000/' $INSTALL_ROOT/alertd/conf/cloudmon.alerting.conf
sed -i 's/cluster.reg.delay.max.millisecond.*/cluster.reg.delay.max.millisecond = 3000/' $INSTALL_ROOT/alertd/conf/cloudmon.alerting.conf
sed -i 's/TopoTaskIntervalMins.*/TopoTaskIntervalMins = 1/' $INSTALL_ROOT/alertd/conf/cloudmon.alerting.conf

exit 0
