module Lotomation
  module Power

    def power_flip_state(name)
      check_value(name) == 'off' ? 'on' : 'off'
    end

    def flip(name)
      name=name.to_s
      actuate(name, power_flip_state(name))
    end

    def actuate(name, state)
      name=name.to_s
      state=state.to_s
      if state != check_value(name)
	Devices.each do |device|
	  device.sub_devices.each do |subdev|
	    if subdev.short_name == "#{name}-#{state}"
	      device.actuate(subdev.data)
	      device.actuate(subdev.data)
	      device.actuate(subdev.data)
	      write_value(name, state)
	      log("flipped #{name}")
	      break
	    end
	  end
	end
      end
    end

    def actuate_all(state)
      state=state.to_s
      Devices.each do |d|
	d.sub_devices.each { |s| d.actuate(s.data) if s.short_name =~ /#{state}$/ }
      end
      Configs['devices']['433Mhz'].each do |name|
	write_value(name, state)
      end
    end
  end
end
