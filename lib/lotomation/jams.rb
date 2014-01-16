module Lotomation
  module Jams

    def jam_get_state
      File.read("#{Configs['status']['dir']}/jam")
    end

    def jam_write_state(value)
      File.write("#{Configs['status']['dir']}/jam", value)
    end
  
  end
end
