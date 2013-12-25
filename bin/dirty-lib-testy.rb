require 'rubygems'
require 'pty'
require 'yaml'

require './lib/lotomation'

include Lotomation

@verbose=true

flip('coloredlight-on')
flip('coloredlight-off')
