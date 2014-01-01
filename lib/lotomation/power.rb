module Lotomation
  module Power

    def power_current_state(name)
      filename="#{Config['status']['dir']}/#{name}"
      if File.exist?(filename)
	File.read(filename)
      else
	File.write(filename, "unknown")
      end
    end

    def power_write_state(name, state)
      File.write("#{Config['status']['dir']}/#{name}", state)
    end

    def power_flip_state(name)
      power_current_state(name) == 'off' ? 'on' : 'off'
    end
    
    def flip(name)
      actuate(name, power_flip_state(name))
    end

    def actuate(name, state)
      if state != power_current_state(name)
	Devices.each do |device|
	  device.sub_devices.each do |subdev|
	    puts subdev.short_name
	    if subdev.short_name =~ /#{name}.+#{state}/
	      device.actuate(subdev.data)
	      power_write_state(name, state)
	      log("flipped #{name}")
	      break
	    end
	  end
	end
      end
    end

    def actuate_all(state)
      Devices.each do |d|
	d.sub_devices.each { |s| d.actuate(s.data) if s.short_name =~ /#{state}$/ }
      end
    end
  end
end
