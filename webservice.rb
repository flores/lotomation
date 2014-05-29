#!/usr/bin/env ruby

require 'sinatra'
require 'thin'
require './lib/lotomation'

include Lotomation

set :bind, '0.0.0.0'
set :port, Configs['webserver']['port']

use Rack::Auth::Basic, "please log in" do |user, pass|
  user == Configs['webserver']['user'] and pass == Configs['webserver']['pass']
end

get '/' do
  @steps_alert = steps_alert
  @punishments = steps_punishments
  erb :index
end

get '/snap' do
  erb :snapshot
end

get '/ghetto-nest' do
  erb :ghetto_nest
end

get '/snap/enforce' do
  check_state('camera')
end

post '/snap/enforce/:state' do |state|
  write_state('camera', state)
  redirect '/'
end

get '/buttoncontrol' do
  erb :buttoncontrol, :layout => false
end

post '/switch/:device/:state' do |device, state|
  device == 'all' ? actuate_all(state) : actuate(device, state)
  redirect '/'
end

post '/flip/:name' do |name|
  flip(name)
  redirect '/'
end

post '/steps/alert' do
  steps_alert
end

post '/tracker/:checkpoint' do |checkpoint|
  rssi = params[:rssi]
  location = checkpoint_interpret_rawlocation(rssi)
  checkpoint_write_location(checkpoint,location)
  "thanks"
end

get '/lo/home' do
  lo_home? ? "yes" : "no"
end

get '/lo/location' do
  lo_location
end

post '/lo/work' do
  write_state('lowork', 'yes')
end

get '/jam/played' do
  check_state('jam')
end

post '/jam/played' do
  write_state('jam', 'true')
  "cool"
end

post '/jam/force' do
  write_state('jam', 'false')
  redirect '/'
end

get '/stereo/input' do
  check_value('stereo-input') 
end

get '/stereo/input/:number' do |input|
  write_value('stereo-input', input)
  redirect '/'
end

# FIXME
post '/locator/enforce' do
  if locator_get_state == 'on'
    if lo_home?
      checkpoint_get_devices('hi-pi').each { |d| actuate(d, 'on') }
    else
      Configs['devices']['433Mhz'].each do |device|
        device =~ /aquarium|stereo/ ? next : actuate(device,'off')
      end
      write_state('jam', 'false')
    end
  end
  "k"
end

post '/locator/:state' do |state|
  locator_write_state(state)
  redirect '/'
end

get '/punishments/enforce' do
  punishments_get_status
end

post '/punishments/enforce/:state' do |state|
  punishments_write_status(state)
  redirect '/'
end

get '/thermostat' do
  check_state('thermostat')
end

get '/thermostat/historical' do
  read_historical_www('hvac', 10)
end

get '/thermostat/:state' do |state|
  log_historical('hvac', "no longer maintaining #{check_value('maintain-temp')}")
  write_state('maintain', 'off')
  log_historical('hvac', "switching to #{state}")
  write_state('thermostat', state)
  redirect request.referrer
end

get '/temperature/:tracker' do |tracker|
  check_value(tracker + '-temperature')
end

post '/temperature/:tracker' do |tracker|
  degrees_f = degrees_convert_to_f(params[:rawtemp])
  write_value(tracker + '-temperature', degrees_f)
  log_historical("trackertemp", "#{tracker} measured #{degrees_f}F")
  "cool"
end

get '/temperature/bed-pi/historical' do
  read_historical_www('hvac', 10)
end

post '/maintain/temp' do
  write_value('maintain-temp', params[:temp])
  log_historical('hvac', "maintain temperature changed to #{params[:temp]}")
  redirect request.referrer
end

get '/maintain/enforce' do
  check_state('maintain')
end

get '/maintain/enforce/:state/:tracker' do |state,tracker|
  log_historical('hvac', "setting maintaining #{check_value('maintain-temp')}")
  write_state('maintain', state)
  write_state('maintain-tracker', tracker)
  redirect request.referrer
end

post '/maintain/enforce' do
  check_state('maintain') == 'on' ? maintain_temp : 'not maintaining temp'
end

post '/nightlight/:state' do |state|
  write_state('nightlight', state)
  redirect '/'
end

