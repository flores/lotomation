#!/usr/bin/env ruby

# this guy constantly scans bluetooth devices and posts signal strength
# directly to some single home automation endpoint

require 'pty'

tracker_mac = "SO:ME:MA:CA:DD:RE:SS"
device_endpoint = "http://192.168.0.xx:80/rest/nodes/nodes_value/cmd"
device_on = "#{device_endpoint}/DON"
device_off = "#{device_endpoint}/DOFF"

zone_max = -60
zone_min = -80

hcitoolpid = fork { exec "hcitool lescan --duplicates" }
Process.detach(hcitoolpid)

PTY.spawn("hcidump |grep -A4 #{tracker_mac}") do |stdin, stdout, pid|
  stdin.each do |line|
    if line =~ /RSSI: (.+)/
      signal_strength = $1.to_i
      puts "detected you at rssi #{signal_strength}"
      if signal_strength <= zone_max && signal_strength >= zone_min
        `curl #{device_on}`
      else
	`curl #{device_off}`
      end
    end
  end
end
