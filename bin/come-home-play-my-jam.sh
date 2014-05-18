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

originalinput=`curl $user:$pass@$host:$port/stereo/input`

echo "lohome: $lohome"
echo "jamplayed: $jamplayed"
echo "current input: $originalinput"

if [[ $lohome == 'yes' ]] && [[ $jamplayed == 'false' ]]; then
    echo "switching to raspberry pi"
    curl $user:$pass@$host:$port/stereo/input/1
    
    jam=`ls $jamdir |grep mp3 |shuf |shuf |head -1`
    echo "playing $jam"
    mplayer -cache 1500 -cache-min 30 -ao alsa:device=hw=1.0 "$jamdir/$jam"
    lastexit = $?
    if [[ $lastexit -ne 0 ]]; then
      echo "there is something wrong with $jam"
    else
      curl -d '' $user:$pass@$host:$port/jam/played
    fi
    
    echo "switching back to input $originalinput"
    curl $user:$pass@$host:$port/stereo/input/$originalinput
fi

