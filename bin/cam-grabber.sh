#!/bin/bash
# this guy curls an ipcam and syncs the image to the webserver
# and backs it up locally

url=`awk '/snapurl/ {print $2}' etc/config.yaml`
backuppath=`awk '/backup/ {print $2}' etc/config.yaml`
targetpath=`awk '/syncpath/ {print $2}' etc/config.yaml`
target=`awk '/host/ {print $2}' etc/config.yaml`
time=`date +%s`
file="$backuppath/snapshot.$time.jpg"

curl $url > $file
scp $file $target\:$targetpath
