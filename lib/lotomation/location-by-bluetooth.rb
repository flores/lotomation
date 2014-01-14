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
            locs[0]
	end
      end
    end

    def checkpoint_get_devices(location)
      Configs['location'][location]['devices']
    end
    
    def checkpoint_time_last(checkpoint)
      File.mtime("#{Configs['status']['dir']}/#{checkpoint}").to_time.to_i
    end

    # FIXME
    def lo_home?
      time = Time.now.to_i
      lastaccessed = checkpoint_time_last('hi-pi')
      difftime = time - lastaccessed
      difftime <= 60 ? true : false
    end

    def locator_write_state(state)
      File.write("#{Configs['status']['dir']}/locator", state)
    end

    def locator_get_state
      File.read("#{Configs['status']['dir']}/locator")
    end

  end
end
