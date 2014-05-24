#!/bin/bash

host=`awk '/host:/ {print $2}' etc/config.yaml`
port=`awk '/port:/ {print $2}' etc/config.yaml`
user=`awk '/user:/ {print $2}' etc/config.yaml`
pass=`awk '/pass:/ {print $2}' etc/config.yaml`

hostname=$(hostname)
lasttemp=0

while true; do
  rawtemp=$(cat /sys/bus/w1/devices/28-000005a1527b/w1_slave |tail -1 |awk -F= '{print $NF}')
  echo $rawtemp

  if [[ $rawtemp -ne $lasttemp ]]; then
    echo changed
    curl -m 5 -d"rawtemp=$rawtemp" $user:$pass@$host:$port/temperature/$hostname &> /dev/null
    lasttemp=$rawtemp
  fi
done
