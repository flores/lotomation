module Lotomation
  module Thermostat

    def degrees_covert_to_f(rawtemperature)
      temp_f = rawtemperature.to_f / 1000 * 9 / 5 + 32
      temp_f.round(2)
    end

  end
end
