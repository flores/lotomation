#!/usr/bin/env ruby

require 'sinatra'
require 'yaml'
require './lib/lotomation'

include Lotomation

post '/switch/:device/:state' do |device, state|
  device == 'all' ? actuate_all(state) : actuate(device, state)
  "yay flipped #{device} to #{state}\n"
end

post '/flip/:name' do |name|
  flip(name)
  "yay flipped #{name}\n"
end

