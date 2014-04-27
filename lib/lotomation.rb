require 'yaml'

["lib", "vendor"].each { |d| $:.unshift d unless $:.include?(d) }
require 'ninja_blocks'
require 'fitgem'

Configs=YAML.load_file('etc/config.yaml')
NinjaBlocks::token = Configs['auth']['ninjablocks']
Devices = NinjaBlocks::Device.list(:device_type => 'rf433')

require 'lotomation/power'
require 'lotomation/steps'
require 'lotomation/location-by-bluetooth'
require 'lotomation/jams'
require 'lotomation/camera'

module Lotomation
  include Power
  include Steps
  include Location_by_bluetooth
  include Jams
  include Camera

  def log(message)
    puts message if Configs['status']['verbose']
  end
end
