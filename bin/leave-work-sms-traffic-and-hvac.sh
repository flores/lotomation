#!/bin/bash

# lotomation credentials
proto=$(awk '/protocol:/ {print $2}' etc/config.yaml)
host=$(awk '/host:/ {print $2}' etc/config.yaml)
port=$(awk '/port:/ {print $2}' etc/config.yaml |head -1)
user=$(awk '/user:/ {print $2}' etc/config.yaml |head -1)
pass=$(awk '/pass:/ {print $2}' etc/config.yaml |head -1)
jamdir=$(awk '/jamdir:/ {print $2}' etc/config.yaml)

# twilio credentials
sid=$(grep -A5 twilio etc/config.yaml |awk '/sid:/ {print $2}')
token=$(grep -A5 twilio etc/config.yaml |awk '/token:/ {print $2}')
sms_to=$(awk '/sms_to:/ {print $2}' etc/config.yaml)
sms_from=$(awk '/sms_from:/ {print $2}' etc/config.yaml)

sms() {
  message=$1
  curl -X POST https://api.twilio.com/2010-04-01/Accounts/$sid/SMS/Messages.json \
  -u $sid:$token \
  -d "From=+1$sms_from" \
  -d "To=+1$sms_to" \
  -d "Body=$message" \
  -m 5
}

web() {
  url=$1
  curl $proto://$user:$pass@$host:$port/$url -m 5 -s -k
}

while true; do
  location=$(web lo/location)
  echo lo is $location

  while [[ $location == "working" ]]; do

    newlocation=$(web lo/location)

    if [[ -z $newlocation ]]; then break; fi
    if [[ ${newlocation} != ${location} ]]; then
      timenow=$(date +%s)
      timetraffic=$(web lo/traffic/work_to_home)
      timetotal=$(($timetraffic + 40))

      sms "I think you just left work and it will take $timetotal min to get home (/w $timetraffic min traffic)"

      timetohome=$(( $timetotal * 60 )) # this should adjust via metrics collection
      timetohome=$(( $timetohome - 600 ))

      echo sleeping for $timetohome
      sleep $timetohome

      afteralertlocation=$(web lo/location)

      if [[ $afteralertlocation == "gone" ]]; then
        temp=$(web temperature/bedpi)
        maintaintemp=$(web /maintain/temp)

        temp_to_i=$(echo $temp |perl -pi -e 's/\.+//g')

        if [[ ${temp_to_i} -eq ${maintaintemp} ]]; then
          sms "Yay I think you're home in 10 mins!  Crib is at $temp F just like you like it"
        else
          if [[ ${temp_to_i} -gt ${maintaintemp} ]]; then
            hvac="airconditioner"
          else
            hvac="heater"
          fi

          sms "Yay I think you're home in 10 mins! Crib is at $temp F but you like it at $maintaintemp, so turning on $hvac. Click $proto://$host:$port/hvac/off to cancel"

          web "/maintain/enforce/on/bedpi"
        fi
      fi
      location=$newlocation
    fi

    sleep 5
  done

  sleep 5
done
