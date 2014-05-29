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
require 'lotomation/weather'
require 'lotomation/traffic'
require 'lotomation/thermostat'

module Lotomation
  include Power
  include Steps
  include Location_by_bluetooth
  include Weather
  include Traffic
  include Thermostat

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

  def log_historical(something, data)
    File.open(Configs['status']['dir'] + '/' + something + '-historical', 'a') do |file|
      file.puts "#{Time.now.ctime}: #{data}\n"
    end
  end

  def read_historical_www(something, lines)
    `tac #{Configs['status']['dir'] + '/' + something + '-historical'} |head -#{lines.to_i}`.gsub(/\n/, '<br \>')
  end

  def check_update_unixtime(file)
    File.mtime(Configs['status']['dir'] + '/' + file).to_time.to_i
  end

end
