#!/bin/bash
# FIXME

target=`awk '/host/ {print $2}' etc/config.yaml`
user=`awk '/user/ {print $2}' etc/config.yaml`
pass=`awk '/user/ {print $2}' etc/config.yaml`

lohome=`curl $user:$pass@$target/lo/home`

if [[ lohome == 'yes' ]]; then
  cd /srv/box/lo
  mplayer -ao alsa:device=hw=1.0 ./Moonlight.mp3
fi
