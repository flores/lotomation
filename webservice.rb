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
  camera_get_state
end

post '/snap/enforce/:state' do |camerastate|
  camera_write_state(camerastate)
  redirect '/'  
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

get '/jam/played' do
  jam_get_state
end

post '/jam/played' do
  jam_write_state(true)
  "cool"
end

post '/jam/force' do
  jam_write_state(false)
  redirect '/'
end

get '/stereo/input' do
  input_get_state.to_s
end

get '/stereo/input/:number' do |input|
  input_write_state(input)
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
      jam_write_state(false)
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
  thermostat_get_state
end

get '/thermostat/:state' do |state|
  write_state('thermostat', state)
  write_state('maintain', 'off')
  redirect request.referrer
end

get '/temperature/:tracker' do |tracker|
  checkpoint_current_temperature(tracker)
end

post '/temperature/:tracker' do |tracker|
  rawtemp = params[:rawtemp]
  checkpoint_write_temperature(tracker, degrees_covert_to_f(rawtemp))
  "cool"
end

post '/maintain/temp' do
  write_value('maintain-temp', params[:temp])
end

get '/maintain/enforce' do
  check_state('maintain')
end

get '/maintain/enforce/:state' do |state|
  write_state('maintain', state)
  redirect request.referrer
end

post '/maintain/enforce' do
  if check_state('maintain') == 'on'
    maint_temp = check_value('maintain-temp').to_i
    current_temp = checkpoint_get_temperature('bedpi').to_i
    if maint_temp > current_temp
      write_state('thermostat', 'air-conditioner')
    elsif maint_temp < current_temp
      write_state('thermostat', 'heater')
    else
      write_state('thermostat', 'off')
    end
  end
end

post '/nightlight/:state' do |state|
  nightlight_write_state(state)
  redirect '/'
end

