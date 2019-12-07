#!/bin/bash

echo "ruok" | nc localhost <:zookeeper_port:>
echo

exit 0
