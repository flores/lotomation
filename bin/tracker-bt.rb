#!/usr/bin/env ruby

# this guy constantly scans bluetooth devices and posts signal strength to the webservice

require 'pty'
require 'yaml'

hostname = `hostname`

config = YAML.load_file('etc/config.yaml')
auth = "#{config['webserver']['user']}:#{config['webserver']['pass']}"
server = "#{config['webserver']['host']}:#{config['webserver']['port']}"

hcitoolpid = fork { exec "hcitool lescan --duplicates" }
Process.detach(hcitoolpid)

PTY.spawn("hcidump |grep -A4 #{config['devices']['fitbit']}") do |stdin, stdout, pid|
  stdin.each do |line|
    if line =~ /RSSI: (.+)/
      `curl -d 'rssi=#{$1}' #{auth}@#{server}/tracker/#{hostname}`
      `curl -d '' #{auth}@#{server}/locator/enforce`
      puts "detected you at rssi #{$1}"
    end
  end
end
