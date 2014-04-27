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
  input = input_get_state().to_i
  input == 1 ? @stereo = "turntable" : @stereo = "hi-pi"
  erb :index
end

get '/snap' do
  erb :snapshot
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
  input_write_state(2)
  jam_write_state(false)
  redirect '/'
end

get '/stereo/input' do
  input_get_state
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
      jam_write_state(false)
    else
      Configs['devices']['433Mhz'].each do |device|
        device =~ /aquarium|stereo/ ? next : actuate(device,'off')
      end
    end
  end
  "k"
end

post '/locator/:state' do |state|
  locator_write_state(state)
  redirect '/'
end
