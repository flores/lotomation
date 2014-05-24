#!/usr/bin/env ruby

require 'yaml'
require 'pi_piper'
include PiPiper

config = YAML.load_file('etc/config.yaml')
auth = "#{config['webserver']['user']}:#{config['webserver']['pass']}"
server = "#{config['webserver']['host']}:#{config['webserver']['port']}"

state = `curl #{auth}@#{server}/thermostat`

if state == "air-conditioner"
  gpio_on = 27
  gpio_off = 17
elsif state == "heater"
  gpio_on = 17
  gpio_off = 27
elsif state == "off"
  [17, 27].each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
    pin.on
  end
  exit
else
  puts "i do not know this device"
  exit
end

# first turn off everything (ac and heater cannot both be on)
# pins are reversed to avoid either turning on at boot/reset
pin = PiPiper::Pin.new(:pin => gpio_off, :direction => :out)
pin.on

pin = PiPiper::Pin.new(:pin => gpio_on, :direction => :out)
pin.off
