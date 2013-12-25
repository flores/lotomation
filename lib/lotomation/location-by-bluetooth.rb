module Lotomation
  module Location_by_bluetooth

    statusdir = Config['status']['dir']

    def checkpoint_set_location(location)
      File.write("#{statusdir}/location", location)
    end

    def checkpoint_get_location
      File.read("#{statusdir}/location")
    end

    def checkpoint_interpret_rawlocation(rawloc)
      Config['location'].each do |niceloc, vals|
	if rawloc <= vals['max'] && rawloc >= vals['max']
	  return niceloc
	end
      end
    end

    def get_devices(location)
      Config['location'][location]['devices']
    end

  end
end
