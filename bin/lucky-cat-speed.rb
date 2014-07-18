#!/usr/bin/env ruby

require 'pi_piper'
include PiPiper

cliarg = ARGV[0]
@pins = [4, 17, 18, 22, 23, 27]

def all_off
  @pins.each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
    pin.on
    puts "turned #{gpio} off"
  end
end

if cliarg == "off"
  all_off
elsif cliarg == "cycle"
  while true do
    @pins.each do |gpio|
      pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
      puts "turned #{gpio} on"
      pin.on
    end
    sleep 30
    all_off
    sleep 15
    @pins.each do |gpio|
      pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
      pin.on
      puts "turned #{gpio} on"
      sleep 5
    end
    all_off
    sleep 15
    @pins.first(3).each do |gpio|
      pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
      pin.on
      puts "turned #{gpio} on"
      sleep 15
    end
    all_off
    sleep 15
    @pins.drop(3).each do |gpio|
      pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
      pin.on
      puts "turned #{gpio} on"
      sleep 15
    end
    all_off
    sleep 15
  end

elsif cliarg == "on"
elsif cliarg == "firston"
  @pins = @pins.first(3)
elsif cliarg == "laston"
  @pins = @pins.drop(3)
else 
  @pins = cliarg.to_i
end

@pins.each do |gpio|
  pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
  pin.on
  puts "turning on #{gpio}"
end
