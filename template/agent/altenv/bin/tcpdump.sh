#!/bin/bash

TCPDUMP=/usr/sbin/tcpdump
LOGDIR=<:agent_root:>/cloudwiz-agent/altenv/var/log
KEEPCNT=5
OPTIONS="-c 10000"

if [ $# -gt 0 ]; then
    OPTIONS="-c $1"
    shift
fi

if [ $# -gt 0 ]; then
    KEEPCNT=$1
    shift
fi

# try to rotate logs first
for (( i=$KEEPCNT; i>1; i-- )); do
    LOGi="$LOGDIR/tcpdump.log.$i"
    LOGi_1="$LOGDIR/tcpdump.log.$((i-1))"
    if [ -f $LOGi_1 ]; then
        rm -f $LOGi
        mv -f $LOGi_1 $LOGi
    fi
done

if [ -f $LOGDIR/tcpdump.log ]; then
    rm -f $LOGDIR/tcpdump.log.1
    mv -f $LOGDIR/tcpdump.log $LOGDIR/tcpdump.log.1
fi

# now try to perform tcpdump
$TCPDUMP $OPTIONS > $LOGDIR/tcpdump.log 2>/dev/null

exit 1
