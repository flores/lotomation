module NinjaBlocks
  
  BASE_URL = "https://api.ninja.is/rest/v0"
  
  module HTTPMethods
    
    def self.included(base)
      # Also add these as class methods.
      base.extend(HTTPMethods)
    end
    
    def get(url,options={})
      execute(:get, url, options)
    end

    def delete(url, options={})
      execute(:delete, url, options)
    end
    
    def put(url, body, options={})
      execute_data(:put, url, body, options)
    end

    def post(url, body, options={})
      execute_data(:post, url, body, options)
    end
    
    def connection
      @connection = Faraday.new(:url => 'https://api.ninja.is')
      @connection.headers['accept'] = 'application/json'
      @connection.headers['Content-Type'] = 'application/json'
      @connection
    end
    
    def execute(method, url, options={})
      response = connection.send(method, build_url(url, options))
      JSON.parse(response.body)
    end
    
    def execute_data(method, url, body, options={})
      response = connection.send(method, build_url(url, options), body)
      JSON.parse(response.body)
    end
    
    def build_url(url, params)
      url = "#{BASE_URL}#{url}" unless url.start_with?('http')
      url = Addressable::URI.parse(url)
      params[:user_access_token] = self.token
      url.query_values = params
      url.to_s
    end
    
    # Takes a (Chronic-parseable) string, an integer (presumed to be a UNIX
    # timestamp), or a Time, and turns it into a timestamp suitable for
    # inclusion in an API URL.
    def interpret_date(date)
      d = Chronic::parse(date) if date.is_a?(String)
      d = Time.at(date) if date.is_a?(Fixnum)
      
      d.utc.to_i * 1000
    end
    
    def token
      @token || NinjaBlocks.token
    end

  end
  
  class Base
    include HTTPMethods
  end
end

