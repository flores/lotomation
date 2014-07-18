#!/usr/bin/env ruby

require 'pi_piper'
include PiPiper

cliarg = ARGV[0]
pins = [4, 17, 18, 22, 23, 27]

if cliarg == "off"
  pins.each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
    pin.off
  end
  puts "turned off all pins"
  exit

elsif cliarg == "on"
elsif cliarg == "firston"
  pins = pins.first(3)
elsif cliarg == "laston"
  pins = pins.drop(3)
else 
  pins = cliarg.to_i
end

pins.each do |gpio|
  pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
  pin.on
  puts "turning on #{gpio}"
end
