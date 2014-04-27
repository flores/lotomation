#!/usr/bin/env ruby

require 'yaml'

gpiomap = Hash.new
gpiomap[0] = [4, 17]
gpiomap[1] = [18, 27]
gpiomap[2] = [22, 23]

config = YAML.load_file('etc/config.yaml')
auth = "#{config['webserver']['user']}:#{config['webserver']['pass']}"
server = "#{config['webserver']['host']}:#{config['webserver']['port']}"

input = `curl #{auth}@#{server}/stereo/input`.to_i
if $? != 0
  puts "something went wrong with curl"
  exit
end
currentinput = File.read("/root/lotomation/stereoinput").to_i

puts input
puts currentinput

if input != currentinput && gpiomap[input]
  puts "firing"
  require 'pi_piper'
  include PiPiper

  gpiomap.each do |k,gpiopins|
    gpiopins.each do |pin|
      PiPiper::Pin.new(:pin => pin, :direction => :out).on
    end
  end
  
  gpiomap[input].each do |gpiopin|
    pin = PiPiper::Pin.new(:pin => gpiopin, :direction => :out)
    pin.off
  end

  File.write("/root/lotomation/stereoinput", input)
end

