module Lotomation
  module Location_by_bluetooth

    def checkpoint_set_location(location)
      File.write("#{Configs['status']['dir']}/location", location)
    end

    def checkpoint_get_location
      File.read("#{Configs['status']['dir']}/location")
    end

    def checkpoint_interpret_rawlocation(rawloc)
      Configs['location'].each do |niceloc, vals|
	if rawloc <= vals['max'] && rawloc >= vals['max']
	  return niceloc
	end
      end
    end

    def checkpoint_get_devices(location)
      Configs['location'][location]['devices']
    end

  end
end
