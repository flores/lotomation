module Lotomation
  module Weather

    def weather(zip)
      file = "#{Configs['status']['dir']}/weather-#{zip}"
      if File.exist?(file)
        if (Time.now - File.mtime(file)) > 1800
          print "file is #{Time.now - File.mtime(file)} seconds old"
          status = weather_update(zip)
        else
          File.read(file)
        end
      else
        weather_update(zip)
      end
    end

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

    def weather_picture_update(zip)
      uri = URI.parse("http://api.wunderground.com/api/#{Configs['auth']['wunderground']}/webcams/q/#{zip}.json")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      if response.code == "200"
        result = JSON.parse(response.body)
        picturearray = Array.new
        result['webcams'].each do |webcam|
          picturearray << webcam['WIDGETCURRENTIMAGEURL']
        end
        picturearray
      else
        "Error"
      end
    end
  end
end
