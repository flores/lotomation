#!/usr/bin/env ruby

require 'yaml'
require 'pi_piper'
include PiPiper

config = YAML.load_file('etc/config.yaml')
auth = "#{config['webserver']['user']}:#{config['webserver']['pass']}"
server = "#{config['webserver']['host']}:#{config['webserver']['port']}"

state = `curl #{auth}@#{server}/thermostat`

if state == "air-conditioner"
  gpio_on = [27, 17]
elsif state == "heater"
  gpio_on = 27
  gpio_off = 17
elsif state == "off"
  gpio_off = [17, 27]
else
  puts "i do not know this device"
  exit
end

# first turn off everything (ac and heater cannot both be on)
# pins are reversed to avoid either turning on at boot/reset
if gpio_off.is_a?(Array)
  gpio_off.each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio.to_i, :direction => :out)
    pin.on
  end
elsif gpio_off
  pin = PiPiper::Pin.new(:pin => gpio_off, :direction => :out)
  pin.on
end

if gpio_on.is_a?(Array)
  gpio_on.each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio.to_i, :direction => :out)
    pin.off
  end
elsif gpio_on
  pin = PiPiper::Pin.new(:pin => gpio_on, :direction => :out)
  pin.off
end
