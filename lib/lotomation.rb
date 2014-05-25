require 'yaml'

["lib", "vendor"].each { |d| $:.unshift d unless $:.include?(d) }
require 'ninja_blocks'
require 'fitgem'
require 'net/http'
require 'uri'
require 'json'
require 'pp'

Configs=YAML.load_file('etc/config.yaml')
NinjaBlocks::token = Configs['auth']['ninjablocks']
Devices = NinjaBlocks::Device.list(:device_type => 'rf433')

require 'lotomation/power'
require 'lotomation/steps'
require 'lotomation/location-by-bluetooth'
require 'lotomation/jams'
require 'lotomation/camera'
require 'lotomation/weather'
require 'lotomation/traffic'
require 'lotomation/thermostat'
require 'lotomation/nightlight'

module Lotomation
  include Power
  include Steps
  include Location_by_bluetooth
  include Jams
  include Camera
  include Weather
  include Traffic
  include Thermostat
  include Nightlight

  def log(message)
    puts message if Configs['status']['verbose']
  end

  def check_state(something)
    if File.exist?(Configs['status']['dir'] + '/' + something)
      File.read(Configs['status']['dir'] + '/' + something)
    else
      write_state(something, "off")
      "off"
    end
  end

  def write_state(something, state)
    File.write(Configs['status']['dir'] + '/' + something, state)
  end

  def check_value(something)
    if File.exist?(Configs['status']['dir'] + '/' + something)
      File.read(Configs['status']['dir'] + '/' + something)
    else
      write_state(something, "unknown")
      "unknown"
    end
  end

  def write_value(something, value)
    File.write(Configs['status']['dir'] + '/' + something, value)
  end 

end
