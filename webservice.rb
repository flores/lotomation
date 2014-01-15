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
  @stepstoday = steps_warning
  @punishments = steps_punishments
  erb :index
end

get '/snap' do
  erb :snapshot
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
end

get '/lo/home' do
  lo_home? ? "yes" : "no"
end

# FIXME
post '/locator/enforce' do
  if locator_get_state == 'on'
    if lo_home?
      checkpoint_get_devices('hi-pi').each { |d| actuate(d, 'on') }
    else
      Configs['devices']['433Mhz'].each do |device|
        device =~ /aquarium/ ? next : actuate(device,'off')
      end
    end
  end
end

post '/locator/:state' do |state|
  locator_write_state(state)
  redirect '/'
end
