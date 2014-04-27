module Lotomation
  module Camera

    def camera_get_state
      if File.exist?("#{Configs['status']['dir']}/camera")
        state = File.read("#{Configs['status']['dir']}/camera")
        state == 'false' ? false : true
      else
        File.write("#{Configs['status']['dir']}/camera", "false")
        false
      end
    end

    def camera_write_state(value)
      File.write("#{Configs['status']['dir']}/camera", value.to_s)
    end
    
  end
end
