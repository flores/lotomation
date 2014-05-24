#!/usr/bin/env ruby

require 'yaml'
require 'pi_piper'
include PiPiper

config = YAML.load_file('etc/config.yaml')
auth = "#{config['webserver']['user']}:#{config['webserver']['pass']}"
server = "#{config['webserver']['host']}:#{config['webserver']['port']}"

state = `curl #{auth}@#{server}/thermostat -m 5`

# for my heater/ac unit:
# pin | purpose (terminal - thermostat wire color)
#  27 | heating call (W - White) + fan (G - Green), connects to 24V AC (R - Red)
#  17 | reversing valve (O - Orange), connects to 24V AC specific to airconditioning (Rc - Red)
#
# my unit has a delay between turning these on and off and in a certain order, ymmv

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
    sleep 2
  end
elsif gpio_off
  pin = PiPiper::Pin.new(:pin => gpio_off, :direction => :out)
  pin.on
end

if gpio_on.is_a?(Array)
  # my heater/ac unit has a delay between turning on 
  gpio_on.each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio.to_i, :direction => :out)
    pin.off
    sleep 5
  end
elsif gpio_on
  pin = PiPiper::Pin.new(:pin => gpio_on, :direction => :out)
  pin.off
end
