#!/usr/bin/env ruby

# this guy runs on a cron and wrecks shit if goals are not met

require "fitgem"
require "yaml"
require "date"

configs = YAML.load_file('etc/config.yaml')

client = Fitgem::Client.new(configs['auth']['fitbit'])
data = client.activities_on_date 'today'
stepstoday = data['summary']['steps']
stepsgoal = configs['goals']['fitbit']['steps']

server = "#{configs['webserver']['ip']}:#{configs['webserver']['port']}"
punishments = Hash.new
punishments = configs['punishments']

now = DateTime.now

puts "i think the hour is #{now.hour}"
punishments.each do |goalhour,punishment|

  puts goalhour
  if now.hour >= goalhour

    if stepstoday < stepsgoal
      punishment['devices'].each {|pain| `curl -d '' http://#{server}/switch/#{pain}/#{punishment['state']}`}
    else
      puts "yay"
    end
  end
end

