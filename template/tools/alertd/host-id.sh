#!/bin/bash

<:java_home:>/bin/java -cp <:install_root:>/alertd/bin/cloudwiz-daemon-*-jar-with-dependencies.jar com.cloudwiz.common.license.Main -i 2>/dev/null

exit 0
