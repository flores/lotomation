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

auth = "#{configs['webserver']['user']}:#{configs['webserver']['pass']}"
server = "#{configs['webserver']['host']}:#{configs['webserver']['port']}"

punishments = Hash.new
punishments = configs['punishments']

now = DateTime.now.hour

punishments.each do |goalhour,punishment|

  if now >= goalhour

    home = `curl http://#{auth}@#{server}/lo/home`
    home == 'yes' ? true : false

    if stepstoday < stepsgoal && home
      punishment['devices'].each {|pain| `curl -d '' http://#{auth}@#{server}/switch/#{pain}/#{punishment['state']}`}
      puts "oh snap son, turned the pain on"
    else
      puts "yay, you got enough steps"
    end
  end
end

