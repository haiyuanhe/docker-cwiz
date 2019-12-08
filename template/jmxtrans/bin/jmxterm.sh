#!/bin/bash

<:java_home:>/bin/java -jar <:install_root:>/jmxtrans/lib/jmxterm-1.0.0-uber.jar -l service:jmx:rmi:///jndi/rmi://172.16.16.100:7200/server -u <username> -p <password>
