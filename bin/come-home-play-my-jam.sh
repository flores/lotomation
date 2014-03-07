#!/bin/bash
# plays a jam when i come home
# FIXME

host=`awk '/host:/ {print $2}' etc/config.yaml`
port=`awk '/port:/ {print $2}' etc/config.yaml`
user=`awk '/user:/ {print $2}' etc/config.yaml`
pass=`awk '/pass:/ {print $2}' etc/config.yaml`
jamdir=`awk '/jamdir:/ {print $2}' etc/config.yaml`

lohome=`curl $user:$pass@$host:$port/lo/home`
jamplayed=`curl $user:$pass@$host:$port/jam/played`

if [[ $lohome == 'yes' ]] && [[ $jamplayed == 'false' ]]; then
  jam=`ls $jamdir |grep mp3 |shuf |head -1`
  echo "playing $jam"
  mplayer -ao alsa:device=hw=1.0 "$jamdir/$jam" && curl -d '' $user:$pass@$host:$port/jam/played
fi

