#!/usr/bin/env ruby

require 'yaml'
require 'curb'
require 'pi_piper'
include PiPiper

config = YAML.load_file('etc/config.yaml')
protocol = config['webserver']['protocol']
auth = "#{config['webserver']['user']}:#{config['webserver']['pass']}"
server = "#{config['webserver']['host']}:#{config['webserver']['port']}"

laststatefile = "#{config['status']['dir']}/thermostat"

hvac = Curl.get("#{protocol}://#{auth}@#{server}/thermostat").body_str
laststate = File.exist?(laststatefile)? File.read(laststatefile) : "off"

# for my heater/ac unit:
# pin | purpose (terminal - thermostat wire color)
#  27 | heating call (W - White) + fan (G - Green), connects to 24V AC (R - Red)
#  17 | reversing valve (O - Orange), connects to 24V AC specific to airconditioning (Rc - Red)
#
# my unit has a delay between turning these on and off and in a certain order, ymmv

if laststate != hvac
  if hvac == "air-conditioner"
    gpio_on = [27, 17]
  elsif hvac == "heater"
    gpio_on = 27
    gpio_off = 17
  elsif hvac == "off"
    gpio_off = [17, 27]
  else
    puts "i do not know this device"
    exit
  end
  puts "changing hvac to #{hvac}"
else
  puts "nothing changed"
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

File.write(laststatefile, hvac)
