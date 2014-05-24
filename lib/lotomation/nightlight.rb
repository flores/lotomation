module Lotomation
  module Nightlight

    def nightlight_write_state(state)
      File.write("#{Configs['status']['dir']}/nightlight", state)
    end

    def nightlight_get_state
      if File.exist?("#{Configs['status']['dir']}/nightlight")
        File.read("#{Configs['status']['dir']}/nightlight")
      else
        nightlight_write_state("off")
        "off"
      end        
    end

    def degrees_covert_to_f(rawtemperature)
      temp_c = rawtemperature.to_f / 1000
      (temp_c * 9 / 5) + 32
    end

    def thermostat_write_state(state)
      File.write("#{Configs['status']['dir']}/thermostat", state)
    end

    def thermostat_get_state
      File.read("#{Configs['status']['dir']}/thermostat")
    end

  end
end
