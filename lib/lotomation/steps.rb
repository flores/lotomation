module Lotomation
  module Steps

    Fit = Fitgem::Client.new(Configs['auth']['fitbit'])

    def steps_today()
      data = Fit.activities_on_date 'today'
      if data['summary']
        data['summary']['steps']
      else
        nil
      end
    end

    def steps_goal()
      Configs['goals']['fitbit']['steps']
    end

    def steps_today_percent
      steps_today*100/steps_goal
    end

    def distances_today()
      data = Fit.activities_on_date 'today'
      data['summary']['distances']
    end

    def steps_alert()
      threshold = Configs['goals']['fitbit']['steps']
      if steps_today.nil?
        "Unknown steps -- FitBit API down"
      elsif steps_today <= threshold
	"FAIL: need #{threshold - steps_today} more steps to pass!"
      else
	"PASS: over by #{steps_today - threshold} steps, good job!"
      end
    end

    def steps_punishments()
      Configs['punishments']
    end

    def punishments_get_status()
      if File.exist?("#{Configs['status']['dir']}/punishments")
        state = File.read("#{Configs['status']['dir']}/punishments")
        state == 'off' ? false : true
      else
        File.write("#{Configs['status']['dir']}/punishments", "off")
        false
      end
    end

    def punishments_write_status(status)
      File.write("#{Configs['status']['dir']}/punishments", status)
    end

  end
end
