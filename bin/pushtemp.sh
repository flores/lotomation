#!/bin/bash

host=`awk '/host:/ {print $2}' etc/config.yaml`
port=`awk '/port:/ {print $2}' etc/config.yaml`
user=`awk '/user:/ {print $2}' etc/config.yaml`
pass=`awk '/pass:/ {print $2}' etc/config.yaml`

rawtemp=$(cat /sys/bus/w1/devices/28-000005a1527b/w1_slave |tail -1 |awk -F= '{print $NF}')

hostname=$(hostname)

echo $rawtemp

curl -d"rawtemp=$rawtemp" $user:$pass@$host:$port/temperature/$hostname
