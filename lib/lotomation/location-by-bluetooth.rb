module Lotomation
  module Location_by_bluetooth

    def checkpoint_write_location(checkpoint,location)
      File.write("#{Configs['status']['dir']}/#{checkpoint}", location)
    end

    def checkpoint_current_location(checkpoint)
      File.read("#{Configs['status']['dir']}/#{checkpoint}")
    end

    def checkpoint_interpret_rawlocation(rawloc)
      Configs['location'].each do |locs,vals|
	if rawloc.to_i <= vals['max'].to_i && rawloc.to_i >= vals['min'].to_i
	    log("i guess #{locs}")
	end
      end
    end

    def checkpoint_get_devices(location)
      Configs['location'][location]['devices']
    end

  end
end
