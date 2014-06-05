module Lotomation
  module Thermostat

    def degrees_convert_to_f(rawtemperature)
      temp_f = rawtemperature.to_f / 1000 * 9 / 5 + 32
      temp_f.round(2)
    end

    def maintain_temp
      maint_temp = check_value('maintain-temp').to_f
      tracker = check_value('maintain-tracker').to_s
      current_temp = check_value("#{tracker}-temperature").to_f

      hvac = check_value('hvac')

      last_state = check_value('hvac-last')

      if maint_temp < current_temp
        if current_temp.between?(maint_temp, maint_temp + 0.5) && hvac == 'heater'
          # do nothing and let temp build up
        elsif ( current_temp >= maint_temp + 1 ) && hvac == 'heater'
          log_historical('hvac', "turning hvac off")
          write_state('hvac', 'off')
        elsif current_temp.between?(maint_temp, maint_temp + 1) && hvac == 'off'
          # do nothing
        else
          if hvac != 'air-conditioner'
            log_historical('hvac', "turning air-conditioner on")
            write_state('hvac', 'air-conditioner')
          end
        end
      elsif maint_temp > current_temp
        if current_temp.between?(maint_temp - 0.5, maint_temp) && hvac == 'air-conditioner'
        elsif ( current_temp <= maint_temp - 1 ) && hvac == 'air-conditioner'
          log_historical('hvac', "turning hvac off")
          write_state('hvac', 'off')
        elsif current_temp.between?(maint_temp - 1, maint_temp) && hvac == 'off'
        else
          if hvac != 'heater'
            log_historical('hvac', "turning heater on")
            write_state('hvac', 'heater')
          end
        end
      else
        if hvac != 'off'
          log_historical('hvac', "turning hvac off")
          write_state('hvac', 'off')
        end
      end
    end

  end
end
