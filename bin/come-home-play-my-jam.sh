#!/bin/bash
# plays a jam when i come home
# FIXME

host=`awk '/host:/ {print $2}' etc/config.yaml`
port=`awk '/port:/ {print $2}' etc/config.yaml`
user=`awk '/user:/ {print $2}' etc/config.yaml`
pass=`awk '/pass:/ {print $2}' etc/config.yaml`

lohome=`curl $user:$pass@$host:$port/lo/home`
jamplayed=`curl $user:$pass@$host:$port/jam/played`

if [[ $lohome == 'yes' ]] && [[ $jamplayed == 'false' ]]; then
  mplayer -ao alsa:device=hw=1.0 shoorahshoorah.mp3 && curl -d '' $user:$pass@$host:$port/jam/played
fi

