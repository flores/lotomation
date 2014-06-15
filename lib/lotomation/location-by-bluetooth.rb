module Lotomation
  module Location_by_bluetooth

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
    
    # FIXME
    def lo_home?
      time = Time.now.to_i
      if check_update_unixtime('bedpi') > check_update_unixtime('hi-pi')
        lastfound = check_update_unixtime('bedpi')
      else
        lastfound = check_update_unixtime('hi-pi')
      end
      difftime = time - lastfound
      difftime <= 180 ? true : false
    end

    def lo_location
      time = Time.now.to_i
      if (time - check_update_unixtime('hi-pi') < 180)
        "in the living room"
      elsif (time - check_update_unixtime('bedpi') < 60)
        "in the bedroom"
      elsif (time - check_update_unixtime('lowork') < 60)
        "working"
      else
        "gone"
      end
    end

  end
end
