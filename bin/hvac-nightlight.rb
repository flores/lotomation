#!/usr/bin/env ruby

require 'yaml'
require 'pi_piper'
include PiPiper

config = YAML.load_file('etc/config.yaml')
auth = "#{config['webserver']['user']}:#{config['webserver']['pass']}"
server = "#{config['webserver']['host']}:#{config['webserver']['port']}"

nightlight = `curl  #{auth}@#{server}/nightlight`

if nightlight == 'on'
  state = `curl #{auth}@#{server}/hvac`
  if state == "air-conditioner"
    gpio_on = 27
    gpio_off = 17
  elsif state == "heater"
    gpio_on = 17
    gpio_off = 27
  elsif state == "off"
    [17, 27].each do |gpio|
      pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
      pin.off
    end
    exit
  else
    puts "i do not know this device"
    exit
  end
  
  pin = PiPiper::Pin.new(:pin => gpio_off, :direction => :out)
  pin.off
  
  pin = PiPiper::Pin.new(:pin => gpio_on, :direction => :out)
  pin.on
end
