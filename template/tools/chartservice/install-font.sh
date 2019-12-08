#!/bin/bash

if [ -f $HOME/.bashrc ]; then
    grep "export PATH=" $HOME/.bashrc | grep chart-rpms
    if [ $? -ne 0 ]; then
        echo 'export PATH=$PATH:<:install_root:>/chart-rpms/usr/sbin:<:install_root:>/chart-rpms/usr/bin' >> $HOME/.bashrc
        echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<:install_root:>/chart-rpms/usr/lib64' >> $HOME/.bashrc
        echo 'export FONTCONFIG_PATH=$FONTCONFIG_PATH:<:install_root:>/chart-rpms/etc/fonts' >> $HOME/.bashrc
    fi
    source $HOME/.bashrc
fi

mkdir -p ~/.fonts
cp -a  <:install_root:>/chart-rpms/msyh.ttf ~/.fonts

exit 0
