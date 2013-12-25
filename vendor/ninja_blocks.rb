# external dependencies

require 'rubygems'
require 'faraday'
require 'rest-client'
require 'json'
require 'chronic'
require 'active_support/time_with_zone'
require 'addressable/uri'

require 'ninja_blocks/version'

module NinjaBlocks
  require 'ninja_blocks/base'
  require 'ninja_blocks/device'
  require 'ninja_blocks/user'
  require 'ninja_blocks/rule'

  def self.token
    @token
  end
  
  def self.token=(token)
    @token = token
  end
end


