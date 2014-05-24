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

  end
end
