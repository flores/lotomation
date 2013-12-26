module Lotomation
  module Power

    def power-current-state(name)
      File.read("#{Config['status']['dir']}/#{name}")
    end

    def power-write-state(name, state)
      File.write("#{Config['status']['dir']}/#{name}", state)
    end

    def flip(name)
      @devices.each do |device|
	device.sub_devices.each do |subdev|
	  if subdev.short_name =~ /name/
	    device.actuate(subdev.data)
	    log("flipped #{name}")
	  else
	    log("#{subdev.short_name} did not match #{name}")
	  end
	end
      end
    end

  end
end
