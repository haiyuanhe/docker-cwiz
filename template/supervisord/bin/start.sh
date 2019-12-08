#!/bin/bash

ALTENV=<:install_root:>/supervisord/altenv
$ALTENV/bin/python $ALTENV/bin/supervisord -c $ALTENV/etc/supervisord.conf --pidfile $ALTENV/var/run/supervisord.pid

#ALTENV=<:agent_root:>/cloudwiz-agent/altenv
#if [ -x "$ALTENV/bin/supervisord" ]; then
#    $ALTENV/bin/python $ALTENV/bin/supervisord -c $ALTENV/etc/supervisord.conf --pidfile $ALTENV/var/run/supervisord.pid
#fi

# update PATH
if [ -f $HOME/.bashrc ]; then
    grep "export PATH=" $HOME/.bashrc | grep supervisord
    if [ $? -ne 0 ]; then
        echo >> $HOME/.bashrc
        echo 'export PATH=<:install_root:>/supervisord/altenv/bin:$PATH' >> $HOME/.bashrc
    fi
fi

exit 0
