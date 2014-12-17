#!/usr/bin/env ruby

require 'sinatra'
require 'thin'
require './lib/lotomation'

include Lotomation

#set :server, :puma

set :bind, '0.0.0.0'
set :port, Configs['webserver']['backendport']
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

get '/la' do
  erb :losangeles_snap
end

get '/tiny-nest' do
  erb :tiny_nest, :layout => false
end

get '/snap/enforce' do
  check_value('snap')
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
  write_value(checkpoint,location)
  "got you at #{location}"
end

get '/lo/home' do
  lo_home? ? "yes" : "no"
end

get '/lo/location' do
  lo_location
end

post '/lo/work' do
  write_value('lowork', 'yes')
end


get '/jam/:location/played' do |location|
  check_value(location + '-jam')
end

post '/jam/:location/played' do
  write_value(location + '-jam', 'true')
  "played #{location} jam"
end

post '/jam/:location/force' do
  write_value(location + '-jam', 'false')
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
  if check_value('locator') == 'on'
    if lo_home?
      checkpoint_get_devices('hi-pi').each { |d| actuate(d, 'on') }
    else
      Configs['devices']['433Mhz'].each do |device|
        device =~ /aquarium|stereo/ ? next : actuate(device,'off')
      end
      write_value('jam', 'false')
    end
  end
  "k"
end

post '/locator/:state' do |state|
  write_value('locator', state)
  redirect request.referrer
end

get '/punishments/enforce' do
  check_value('punishments')
end

post '/punishments/enforce' do
  if check_value('punishments') == 'on'
    steps_punishments_enforce
    "okay"
  else
    "not enforced"
  end
end

get '/hvac' do
  check_value('hvac')
end

get '/hvac/historical' do
  read_historical_www('hvac', 12)
end

get '/hvac/:state' do |state|
  if check_value('maintain') == 'on'
    log_historical('hvac', "no longer maintaining #{check_value('maintain-temp')}")
    write_value('maintain', 'off')
  end
  log_historical('hvac', "switching to #{state}")
  write_value('hvac', state)
  redirect request.referrer
end

get '/temperature/:tracker' do |tracker|
  check_value('temperature-' + tracker)
end

post '/temperature/:tracker' do |tracker|
  degrees_f = degrees_convert_to_f(params[:rawtemp])
  write_value('temperature-' + tracker, degrees_f)
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
  check_value('maintain')
end

post '/maintain/enforce' do
  check_value('maintain') == 'on' ? maintain_temp : "not maintaining temp"
end

get '/maintain/enforce/:state/:tracker' do |state,tracker|
  log_historical('hvac', "setting maintaining #{check_value('maintain-temp')} to #{state}")
  write_value('maintain', state)
  write_value('maintain-tracker', tracker)
  if request.referrer
    redirect request.referrer
  else
    "OK"
  end
end

get '/nightlight' do
  check_value('nightlight')
end

post '/nightlight/:state' do |state|
  write_value('nightlight', state)
  redirect request.referrer
end

get '/traffic/:direction' do |direction|
  traffic(direction)
end

post '/door' do
  write_value('frontdoor', "open")
  sms_out("#{Time.now.ctime} - front door opened") unless lo_home?
end

get '/vpn/response/time' do
  vpn_response_time
end

get '/vpn/server/:command' do |command|
  openvpn_server(command)
end

post '/twilio/sms' do
  if check_value('sms-in') == 'on'
    bodyfull=params[:Body]
    @reply = sms_in(bodyfull)
  else
    @reply = "sorry, sms is off.  click #{Configs['webserver']['protocol']}://#{Configs['webserver']['host']}:#{Configs['webserver']['port']}/sms-in/enforce/on to enable"
  end
  erb :twilio_response, :layout => false
end

post '/:configuration/enforce/:state' do |configuration,state|
  write_value(configuration, state)
  redirect request.referrer
end

get '/:configuration/state' do |configuration|
  check_value(configuration)
end

get '/updatetime/human/:file' do |file|
  check_update_humantime(file)
end
