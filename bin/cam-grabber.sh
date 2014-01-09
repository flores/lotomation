#!/bin/bash
# this guy curls an ipcam and syncs the image to the webserver
# and backs it up locally

url=`awk '/snapshoturl/ {print $2}' etc/config.yaml`
path=`awk '/syncpath/ {print $2}' etc/config.yaml`
target=`awk '/ip/ {print $2}' etc/config.yaml`

time=`date +%s`

file="snapshot.$time.jpg"

curl $url > /snapshots/$file

scp /snapshots/$file $target\:$path
