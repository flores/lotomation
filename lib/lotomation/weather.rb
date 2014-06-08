module Lotomation
  module Weather

    def weather(city)
      #if city =~ /^(.+), (.+)$/
        #state = $2
        #city = $1.gsub(' ', '_')

        #print city
        #print state
        
        #file = "#{Configs['status']['dir']}/weather-#{city}-#{state}"
        file = "#{Configs['status']['dir']}/weather-#{city}"
        if File.exist?(file)
          if (Time.now - File.mtime(file)) > 1800
            print "file is #{Time.now - File.mtime(file)} seconds old"
            status = weather_update(city)
          else
            File.read(file)
          end
        else
          weather_update(city)
        end
      #end
    end
   
#    def weather_update(city, state)
    def weather_update(zip)
      uri = URI.parse("http://api.wunderground.com/api/#{Configs['auth']['wunderground']}/conditions/q/#{zip}.json")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
 
      response = http.request(request)
 
      if response.code == "200"
        result = JSON.parse(response.body)
        
        weather = result['current_observation']['feelslike_f'] + 'F, ' +
          result['current_observation']['weather']
        File.write("#{Configs['status']['dir']}/weather-#{zip}", weather)
        weather
      else
        "Error"
      end
    end
    
  end
end
