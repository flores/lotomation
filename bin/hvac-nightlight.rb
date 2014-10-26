#!/usr/bin/env ruby

# lo's really goofy HVAC checking nightlight!
# powers a LED nightlight connected to GPIO on a Raspberry Pi
# if the HVAC is set to maintain a temperature, gpio pin 17 is on
# if not, gpio pin 27 is on

require 'yaml'
require 'pi_piper'
include PiPiper

config = YAML.load_file('etc/config.yaml')
auth = "#{config['webserver']['user']}:#{config['webserver']['pass']}"
proto = "#{config['webserver']['protocol']}"
server = "#{config['webserver']['host']}"
laststatefile = "#{config['status']['dir']}/nightlight_check"

nightlight = `curl -k #{proto}://#{auth}@#{server}/nightlight`

if nightlight == 'on'

  currentstate = `curl -k #{proto}://#{auth}@#{server}/maintain/enforce`
  laststate = File.exist?(laststatefile) ? File.read(laststatefile) : "off"

  if currentstate != laststate
    if currentstate == "on"
      gpio_on = 17
      gpio_off = 27
    else
      gpio_on = 27
      gpio_off = 17
    end

    pin = PiPiper::Pin.new(:pin => gpio_off, :direction => :out)
    pin.off

    pin = PiPiper::Pin.new(:pin => gpio_on, :direction => :out)
    pin.on

    File.write(laststatefile, currentstate)
  end

else

  [17, 27].each do |gpio|
    pin = PiPiper::Pin.new(:pin => gpio, :direction => :out)
    pin.off
  end

end
