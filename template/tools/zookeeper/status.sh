#!/bin/bash

echo "status" | nc localhost <:zookeeper_port:>
echo

exit 0
