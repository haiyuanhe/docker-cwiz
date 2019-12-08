#!/bin/bash


echo "======================================================================================"
echo "NOTE: This will recreate all certs "
echo "======================================================================================"

read -p "Are you sure to update all certs: (y|n): " ans

if [ "$ans" = "n" ]; then
    rm -rf  <:install_root:>/certs.bak
    mv <:install_root:>/certs <:install_root:>/certs.bak
    <:install_root:>/create-ssl-all-x.sh
else
    exit 0
fi




