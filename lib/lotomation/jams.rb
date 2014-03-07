module Lotomation
  module Jams

    def jam_get_state
      File.read("#{Configs['status']['dir']}/jam")
    end

    def jam_write_state(value)
      File.write("#{Configs['status']['dir']}/jam", value.to_s)
    end
    
    def input_get_state
      if File.exist?(filename)
        File.read("#{Configs['status']['dir']}/stereoinput")
      else
        File.write("#{Configs['status']['dir']}/jam", 2)
      end
    end

    def input_write_state(value)
      File.write("#{Configs['status']['dir']}/stereoinput", value.to_s)
    end
  
  end
end
