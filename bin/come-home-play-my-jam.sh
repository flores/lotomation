#!/bin/bash
# FIXME

host=`awk '/host:/ {print $2}' etc/config.yaml`
port=`awk '/port:/ {print $2}' etc/config.yaml`
user=`awk '/user:/ {print $2}' etc/config.yaml`
pass=`awk '/pass:/ {print $2}' etc/config.yaml`

lohome=`curl $user:$pass@$host:$port/lo/home`

if [[ $lohome == 'yes' ]]; then
  mplayer -ao alsa:device=hw=1.0 "/srv/box/lo/Moonlight.mp3"
fi

