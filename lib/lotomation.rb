require 'yaml'

["lib", "vendor"].each { |d| $:.unshift d unless $:.include?(d) }
require 'ninja_blocks'
require 'fitgem'

Config=YAML.load_file('etc/config.yaml')
NinjaBlocks::token = Config['auth']['ninjablocks']
Devices = NinjaBlocks::Device.list(:device_type => 'rf433')             

require 'lotomation/power'
require 'lotomation/steps'
require 'lotomation/location-by-bluetooth'

module Lotomation
  include Power
  include Steps
  include Location_by_bluetooth

  def log(message)
    puts message if Config['status']['verbose']
  end
end
