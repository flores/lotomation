#!/usr/bin/env ruby

require 'sinatra'
require 'thin'
require './lib/lotomation'

include Lotomation

set :bind, '0.0.0.0'
set :port, Configs['webserver']['port']
set :protection, :except => [:http_origin]

use Rack::Protection::HttpOrigin, :origin_whitelist => Configs['webserver']['originwhitelist']

use Rack::Auth::Basic, "please log in" do |user, pass|
  (user == Configs['webserver']['user'] and pass == Configs['webserver']['pass']) || (user == Configs['webserver']['demouser'] and pass == Configs['webserver']['demopass'])
end

get '/' do
  erb :index
end

get '/full' do
  erb :bigremote
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
  redirect request.referrer
end

get '/buttoncontrol/hvac' do
  erb :buttoncontrol_hvac, :layout => false
end

get '/buttoncontrol/index' do
  erb :buttoncontrol_index, :layout => false
end

get '/buttoncontrol/tempknob' do
  erb :temp_knob, :layout => false
end

get '/panel/index' do
  @steps_alert = steps_alert
  @punishments = steps_punishments
  erb :panel_index, :layout => false
end

post '/switch/:device/:state' do |device, state|
  device == 'all' ? actuate_all(state) : actuate(device, state)
  redirect request.referrer
end

post '/flip/:name' do |name|
  flip(name)
  redirect request.referrer
end

post '/steps/alert' do
  steps_alert
end

post '/tracker/:checkpoint' do |checkpoint|
  rssi = params[:rssi]
  location = checkpoint_interpret_rawlocation(rssi)
  write_state(checkpoint,location)
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
  redirect request.referrer
end

get '/stereo/input' do
  check_value('stereo-input') 
end

get '/stereo/input/:number' do |input|
  write_value('stereo-input', input)
  redirect request.referrer
end

# FIXME
post '/locator/enforce' do
  if check_state('locator') == 'on'
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
  write_state('locator', state)
  redirect request.referrer
end

get '/punishments/enforce' do
  check_state('punishments')
end

post '/punishments/enforce/:state' do |state|
  write_state('punishments',state)
  redirect request.referrer
end

get '/hvac' do
  check_state('hvac')
end

get '/hvac/historical' do
  read_historical_www('hvac', 12)
end

get '/hvac/:state' do |state|
  if check_state('maintain') == 'on'
    log_historical('hvac', "no longer maintaining #{check_value('maintain-temp')}")
    write_state('maintain', 'off')
  end
  log_historical('hvac', "switching to #{state}")
  write_state('hvac', state)
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

get '/maintain/temp' do
  check_value('maintain-temp')
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
  log_historical('hvac', "setting maintaining #{check_value('maintain-temp')} to #{state}")
  write_state('maintain', state)
  write_state('maintain-tracker', tracker)
  if request.referrer
    redirect request.referrer
  else
    "OK"
  end
end

post '/maintain/enforce' do
  check_state('maintain') == 'on' ? maintain_temp : 'not maintaining temp'
end

get '/nightlight' do
  check_state('nightlight')
end

post '/nightlight/:state' do |state|
  write_state('nightlight', state)
  redirect '/'
end

get '/traffic/:direction' do |direction|
  traffic(direction)
end

post '/door' do
  write_state('frontdoor', "open")
  sms_out("#{Time.now.ctime} - front door opened")
end

post '/twilio/sms' do
  bodyfull=params[:Body]
  @reply = sms_in(bodyfull)
  erb :twilio_response, :layout => false
end
