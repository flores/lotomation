module Lotomation
  module Weather

    def weather(city)
      if city =~ /^(.+), (.+)$/
        state = $2
        city = $1.gsub(' ', '_')

        print city
        print state
        
        file = "#{Configs['status']['dir']}/weather-#{city}-#{state}"
        if File.exist?(file)
          if (Time.now - File.mtime(file)) > 200
            print "file is #{Time.now - File.mtime(file)} seconds old"
            status = weather_update(city, state)
          else
            File.read(file)
          end
        else
          weather_update(city, state)
        end
      end
    end
   
    def weather_update(city, state)
      uri = URI.parse("http://api.wunderground.com/api/#{Configs['auth']['wunderground']}/conditions/q/#{state}/#{city}.json")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
 
      response = http.request(request)
 
      if response.code == "200"
        result = JSON.parse(response.body)
        
        weather = result['current_observation']['feelslike_f'] + 'F, ' +
          result['current_observation']['weather'] + ', ' +
          result['current_observation']['wind_string'] + ' wind'
        File.write("#{Configs['status']['dir']}/weather-#{city}-#{state}", weather)
        weather
      else
        "Error"
      end
    end
    
  end
end
