module Lotomation
  module Weather

    def weather(zip)
      data = "weather-" + zip
      if seconds_since_last_update(data) > 1800
        weather_update(zip)
      else
        check_value(data)
      end
    end

    def weather_update(zip)
      uri = URI.parse("http://api.wunderground.com/api/#{Configs['auth']['wunderground']}/conditions/q/#{zip}.json")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      if response.code == "200"
        result = JSON.parse(response.body)

        weather = result['current_observation']['feelslike_f'] + ', ' +
          result['current_observation']['weather']
        write_value("weather-" + zip, weather)
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
