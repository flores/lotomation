#!/bin/bash

host=`awk '/host:/ {print $2}' etc/config.yaml`
port=`awk '/port:/ {print $2}' etc/config.yaml`
user=`awk '/user:/ {print $2}' etc/config.yaml`
pass=`awk '/pass:/ {print $2}' etc/config.yaml`

hostname=$(hostname)
lasttemp=0

while true; do
  rawtemp=$(tail -1 /sys/bus/w1/devices/*/w1_slave |awk -F= '{print $NF}')
  echo $rawtemp

  if [[ $rawtemp -ne $lasttemp ]]; then
    echo changed
    curl -m 5 -d"rawtemp=$rawtemp" $user:$pass@$host:$port/temperature/$hostname &> /dev/null
    lasttemp=$rawtemp
  fi
done
