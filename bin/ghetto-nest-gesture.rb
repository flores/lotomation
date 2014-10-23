#!/usr/bin/env ruby

require 'pty'
require 'yaml'
require 'pi_piper'
include PiPiper

hostname = `hostname`

config = YAML.load_file('etc/config.yaml')
proto = config['webserver']['protocol']
auth = "#{config['webserver']['user']}:#{config['webserver']['pass']}"
server = "#{config['webserver']['host']}:#{config['webserver']['port']}"

# led indicators to let me know when my hand is in range
led_hvac_red = PiPiper::Pin.new(:pin => 22, :direction => :out)
led_hvac_green  = PiPiper::Pin.new(:pin => 23, :direction => :out)

counter = 0

PTY.spawn("./bin/ultrasonic_distance") do |stdin, stdout, pid|
  stdin.each do |line|
    if line.to_f.between?(1,15)
      counter+=1
      puts "got #{line.to_f} and counter at #{counter}"
      led_hvac_red.on
      if counter == 3
        puts "turning off"
        `curl #{proto}://#{auth}@#{server}/hvac/off &`
      end
    elsif line.to_f.between?(25,80)
      counter+=1
      puts "got #{line.to_f} and counter at #{counter}"
      led_hvac_green.on
      if counter == 3
        puts "turning on hvac"
        `curl #{proto}://#{auth}@#{server}/hvac/air-conditioner &`
      end
    else
      led_hvac_red.off
      led_hvac_green.off

      puts "did not act on #{line}"
      counter = 0
    end
  end
end
