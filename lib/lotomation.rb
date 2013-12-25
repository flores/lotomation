require 'yaml'

["lib", "vendor"].each { |d| $:.unshift d unless $:.include?(d) }
require 'ninja_blocks'

Config=YAML.load_file('etc/config.yaml')
NinjaBlocks::token = Config['auth']['ninjablocks']
@devices = NinjaBlocks::Device.list(:device_type => 'rf433')
@verbose = Config['status']['verbose']

require 'lotomation/power'
#require 'lotomation/steps'
require 'lotomation/location-by-bluetooth'

module Lotomation
  include Power
#  include Steps
  include Location_by_bluetooth

  def log(message)
    puts message if @verbose
  end
end
