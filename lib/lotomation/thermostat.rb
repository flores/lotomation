module Lotomation
  module Thermostat

    def checkpoint_write_temperature(checkpoint,temperature)
      File.write("#{Configs['status']['dir']}/#{checkpoint}-temperature", temperature)
    end

    def checkpoint_current_temperature(checkpoint)
      if File.exist?("#{Configs['status']['dir']}/#{checkpoint}-temperature")
        File.read("#{Configs['status']['dir']}/#{checkpoint}-temperature")
      else
        checkpoint_write_temperature(0)
        0
      end        
    end

    def degrees_covert_to_f(rawtemperature)
      temp_c = rawtemperature / 1000
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
