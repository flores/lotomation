module Lotomation
  module Steps

    Fit = Fitgem::Client.new(Configs['auth']['fitbit'])

    def steps_today()
      file = "#{Configs['status']['dir']}/steps"
      if (Time.now - File.mtime(file)) > 600
        print "#{file} is #{Time.now - File.mtime(file)} seconds old"
        data = Fit.activities_on_date 'today'
        data['summary'] ? steps = data['summary']['steps'] : steps = 0

        write_value('steps', steps)
        steps
      else
        check_value('steps')
      end
    end

    def steps_goal()
      Configs['goals']['fitbit']['steps']
    end

    def steps_today_percent
      steps_today.to_i*100/steps_goal
    end

    def distances_today()
      data = Fit.activities_on_date 'today'
      data['summary']['distances']
    end

    def steps_alert()
      threshold = Configs['goals']['fitbit']['steps']
      steps = steps_today.to_i
      if steps == 0
        "Unknown steps -- FitBit API down"
      elsif steps <= threshold
        "FAIL: need #{threshold - steps} more steps to pass!"
      else
        "PASS: over by #{steps - threshold} steps, good job!"
      end
    end

    def steps_punishments()
      Configs['punishments']
    end

  end
end
