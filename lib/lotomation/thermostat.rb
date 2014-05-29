module Lotomation
  module Thermostat

    def degrees_convert_to_f(rawtemperature)
      temp_f = rawtemperature.to_f / 1000 * 9 / 5 + 32
      temp_f.round(2)
    end

    def maintain_temp
      maint_temp = check_value('maintain-temp').to_f
      current_temp = check_value('bedpi-temperature').to_f
      hvac = check_value('thermostat')

      if maint_temp < current_temp
        if current_temp.between?(maint_temp, maint_temp + 0.5) && hvac == 'heater'
          # do nothing and let temp build up
        elsif ( current_temp >= maint_temp + 0.5 ) && hvac == 'heater'
          write_state('thermostat', 'off')
        elsif current_temp.between?(maint_temp, maint_temp + 0.7) && hvac == 'off'
          # do nothing
        else
          log_historical('hvac', "turning #{hvac} on")
        end
      elsif maint_temp > current_temp
        if current_temp.between?(maint_temp - 0.5, maint_temp) && hvac == 'air-conditioner'
        elsif ( current_temp <= maint_temp - 0.5 ) && hvac == 'air-conditioner'
          write_state('thermostat', 'off')
        elsif current_temp.between?(maint_temp - 0.7, maint_temp) && hvac == 'off'
        else
          write_state('thermostat', 'heater')
        end
      else
        write_state('thermostat', 'off')
      end
    end

  end
end
