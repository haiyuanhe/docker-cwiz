#!/bin/sh

CERT_ROOT=<:install_root:>/certs/elasticsearch

rm -rf $CERT_ROOT/ca/
rm -rf $CERT_ROOT/server/
rm -rf $CERT_ROOT/client/
rm -rf $CERT_ROOT/crl/
rm -f $CERT_ROOT/*.jks
rm -f $CERT_ROOT/*.pem
rm -f $CERT_ROOT/*.p12
rm -f $CERT_ROOT/*.csr
rm -f Readme.txt
