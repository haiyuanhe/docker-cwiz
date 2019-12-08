#!/bin/bash

INSTALL_ROOT=<:install_root:>
TMP_DIR=$INSTALL_ROOT/tmp/agent
AGENT_ROOT=$INSTALL_ROOT/agent
DOWNLOAD_DIR=$INSTALL_ROOT/nginx/download/agent
PLATFORMS=( "Debian" "RedHat" "Ubuntu" "Azure" )

rm -rf $TMP_DIR/*
mkdir -p $TMP_DIR
pushd $TMP_DIR

for platform in ${PLATFORMS[@]}
do
    if [ ! -d "$DOWNLOAD_DIR/$platform" ]; then
        continue
    fi

    tar --strip-components=1 -z -xf "$DOWNLOAD_DIR/$platform/agent.tar.gz"
    cp -f $AGENT_ROOT/version.json $TMP_DIR/cloudwiz-agent/
    cp -f $AGENT_ROOT/cloudwiz-agent.service $TMP_DIR/cloudwiz-agent/
    cp -f $AGENT_ROOT/bin/agent_watcher.sh $TMP_DIR/cloudwiz-agent/
    cp -rf $AGENT_ROOT/agent/* $TMP_DIR/cloudwiz-agent/agent/
    cp -rf $AGENT_ROOT/altenv/* $TMP_DIR/cloudwiz-agent/altenv/
    cp -rf $AGENT_ROOT/uagent/* $TMP_DIR/cloudwiz-agent/uagent/
    cp -f $INSTALL_ROOT/umanager/.gnupg/pubring.gpg $TMP_DIR/cloudwiz-agent/.gnupg/
    cp -f $INSTALL_ROOT/umanager/.gnupg/trustdb.gpg $TMP_DIR/cloudwiz-agent/.gnupg/
    cp -f $INSTALL_ROOT/agent/filebeat/filebeat.yml $TMP_DIR/cloudwiz-agent/filebeat/

    sed -i "s/https/<:agent_protocol:>/" $TMP_DIR/cloudwiz-agent/uagent/uagent.py

    tar cfz agent.tar.gz cloudwiz-agent
    /bin/bash -c "md5sum agent.tar.gz | cut -d' ' -f1 > agent.tar.gz.md5"
    chown $USER:$USER agent.tar.gz
    chown $USER:$USER agent.tar.gz.md5
    rm -rf cloudwiz-agent
    mv -f agent.tar.gz $DOWNLOAD_DIR/$platform/
    mv -f agent.tar.gz.md5 $DOWNLOAD_DIR/$platform/
done

popd

rm -rf $TMP_DIR/*

exit 0
