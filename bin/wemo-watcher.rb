#!/usr/bin/env ruby

# polls the webservice and pushes to wemos running on the local network.

require 'wemo'
require 'yaml'

config = YAML.load_file('etc/config.yaml')

devices = config['devices']['wemo']
proto = config['webserver']['protocol']
auth = "#{config['webserver']['user']}:#{config['webserver']['pass']}"
server = config['webserver']['host']
statedir = "/tmp/"

while true do
  devices.each do |device|
    if File.exist?(statedir + device)
      laststate = File.read(statedir + device)
    else
      laststate = "unknown"
    end

    currentstate = `curl -k -s #{proto}://#{auth}@#{server}/#{device}/state`.chomp

    if currentstate && currentstate != laststate
      currentstate == 'on' ? Wemo.on(device) : Wemo.off(device)
      puts "flipped #{device} to #{currentstate}"
      File.write(statedir + device, currentstate)
    end
  end

  sleep 1
end
