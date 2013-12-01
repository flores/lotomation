#!/usr/bin/env ruby

require 'pty'
require 'yaml'
require 'ninja_blocks'

# set configs
CONFIG=YAML.load_file('etc/config.yaml')

# This should maybe be database, so placeholders
STATUSDIR='/tmp/lotomation'

unless File.directory?(STATUSDIR)
  `mkdir #{STATUSDIR}`
end

def checkpoint_set_location(location)
  File.write("#{STATUSDIR}/location", location)
end

def checkpoint_get_location
  File.read("#{STATUSDIR}/location")
end

def checkpoint_interpret_rawlocation(rawlocation)
  if rawlocation <= CONFIG['location']['doorcouch']['min']
    "doorcouch"
  elsif rawlocation < CONFIG['location']['middle']['max'] && 
    rawlocation > CONFIG['location']['middle']['min']
    "middle"
  end
end

def set_devices(location)
  CONFIG['location'][location]['devices']
end

# Calling up to the NinjaBlocks API
NinjaBlocks::token = CONFIG['auth']['ninjablocks']
DEVICES = NinjaBlocks::Device.list(:device_type => 'rf433')

def flip(name)
  DEVICES.each do |device|
    device.sub_devices.each do |subdevice|
      if subdevice.short_name =~ /#{name}/
	dev.actuate(subdevice.data)
      end
    end
  end
end

# Gross and listen inside hcidump
begin
  PTY.spawn("hcidump |grep -A3 #{CONFIG['beacon']['fitbit']}")
  do |stdin, stdout, pid|
    begin
      stdin.each do |line|
	if line =~ /RSSI: (.+?)\n/
	  rawloc = $1.to_i
	  location = checkpoint_interpret_rawlocation(rawloc)
	  if location != checkpoint_get_location
	    checkpoint_set_location(location)
	    flip(set_devices(location))
	  end
	end
      end
    end
  end
end
