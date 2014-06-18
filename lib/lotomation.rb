require 'yaml'

require 'fitgem'
require 'twilio-ruby'
require 'net/http'
require 'uri'
require 'json'
require 'pp'

Configs=YAML.load_file('etc/config.yaml')

["lib/lotomation", "vendor"].each do |dir|
  $:.unshift dir
  Dir[dir + "/*.rb"].each { |lib| puts lib; require "./" + lib.gsub(".rb",'') }
end

NinjaBlocks::token = Configs['auth']['ninjablocks']
Devices = NinjaBlocks::Device.list(:device_type => 'rf433')

module Lotomation
  include Power
  include Steps
  include Location_by_bluetooth
  include Weather
  include Traffic
  include Thermostat
  include Sms

  def log(message)
    puts message if Configs['status']['verbose']
  end

  def sanitize(something)
    something.gsub(/[^0-9A-z.\-\ ]/, '')
  end

  def all_states
    status=''
    Dir[Configs['status']['dir'] + "/*"].each do |file|
      if file =~ /historical/
        next
      else
        status = "#{status}\n#{file.gsub(/#{Configs['status']['dir']}\//, '')}: #{File.read(file)}"
        puts "#{file}: #{File.read(file)}"
      end
    end
    status
  end

  def check_state(something)
    something = sanitize(something)
    if File.exist?(Configs['status']['dir'] + '/' + something)
      File.read(Configs['status']['dir'] + '/' + something)
    else
      write_state(something, "off")
      "off"
    end
  end

  def write_state(something, state)
    something = sanitize(something)
    File.write(Configs['status']['dir'] + '/' + something, state)
  end

  def check_value(something)
    something = sanitize(something)
    if File.exist?(Configs['status']['dir'] + '/' + something)
      File.read(Configs['status']['dir'] + '/' + something)
    else
      write_state(something, "unknown")
      "unknown"
    end
  end

  def write_value(something, value)
    something = sanitize(something)
    File.write(Configs['status']['dir'] + '/' + something, value)
  end

  def log_historical(something, data)
    something = sanitize(something)
    File.open(Configs['status']['dir'] + '/' + something + '-historical', 'a') do |file|
      file.puts "#{Time.now.ctime}: #{data}\n"
    end
  end

  def read_historical_www(something, lines)
    something = sanitize(something)
    `tac #{Configs['status']['dir'] + '/' + something + '-historical'} |head -#{lines.to_i}`.gsub(/\n/, '<br \>')
  end

  def check_update_unixtime(file)
    something = sanitize(file)
    File.mtime(Configs['status']['dir'] + '/' + file).to_time.to_i
  end

end
