#!/usr/bin/env ruby

require "fitgem"
require "optparse"

require "./lib/lotomation"

include Lotomation
options = {}

optparse = OptionParser.new do|opts|
  options[:steps]=10000
  opts.on( '-s', '--steps <int>', 'stepthreshold' ) do |steps|
    options[:steps] = steps.to_i
  end
  opts.on( '-v', '--verbose', 'verbose logging' ) do |verbose|
    @verbose=true
  end
end

optparse.parse!

client = Fitgem::Client.new(Config['auth']['fitbit'])
data = client.activities_on_date 'today'
todayssteps = data['summary']['steps']

if todayssteps <= options[:steps]
  flip('coloredlight-on')
  log("goal: #{options[:steps]} steps")
  log("so far today: #{todayssteps} steps")
  puts "FAIL: need #{options[:steps] - todayssteps} more steps to pass!"
else
  flip('coloredlight-off')
  log("goal: #{options[:steps]} steps")
  log("so far today: #{todayssteps} steps")
  puts "PASS: you're over your goal by #{todayssteps - options[:steps]} steps"
end

