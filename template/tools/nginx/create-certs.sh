#!/bin/bash

hash openssl 2>/dev/null
if [ $? -ne 0 ]; then
    echo "OpenSSL not available, using default cert."
    exit 0
fi

rm -f <:install_root:>/nginx/conf/nginx.crt
rm -f <:install_root:>/nginx/conf/nginx.key

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout <:install_root:>/nginx/conf/nginx.key -out <:install_root:>/nginx/conf/nginx.crt << EOF
CN
Beijing
Beijing
Cloudwiz
Cloudwiz
<:host_ip:>
cwiz@cloudwiz.cn
EOF

echo

exit 0
