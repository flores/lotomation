#!/usr/bin/env ruby

require 'pi_piper'
include PiPiper

cliarg = ARGV[0]

if cliarg == "off"
  pins = [4, 17, 18, 27, 22, 23]
  pins.each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
    pin.off
  end
elsif cliarg == "on"
  pins = [4, 17, 18, 27, 22, 23]
  pins.each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
    pin.on
  end
elsif cliarg == "firston"
  pins = [4, 17, 18]
  pins.each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
    pin.on
  end

elsif cliarg == "laston"
  pins = [27, 22, 23]
  pins.each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
    pin.on
  end
else 
  puts "turning on #{cliarg}"
  pin = PiPiper::Pin.new(:pin => cliarg.to_i, :direction => :out)
  pin.on
end 
