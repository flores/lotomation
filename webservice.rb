#!/usr/bin/env ruby

require 'sinatra'
require 'yaml'
require './lib/lotomation'

include Lotomation

post '/flip/:name' do |name|
  pie = flip(name)
  "yay"
end

