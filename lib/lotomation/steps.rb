module Lotomation
  module Steps

    Fit = Fitgem::Client.new(Configs['auth']['fitbit'])

    def steps_today()
      data = Fit.activities_on_date 'today'
      data['summary']['steps']
    end

    def distances_today()
      data = Fit.activities_on_date 'today'
      data['summary']['distances']
    end

    def steps_alert()
      threshold = Configs['goals']['fitbit']['steps']
      if steps_today <= threshold
	actuate_all('on')
	"FAIL: need #{threshold - steps_today} more steps to pass!"
      else
	actuate_all('off')
	"PASS: over by #{steps_today - threshold} steps, good job!"
      end
    end

    def steps_warning()
      threshold = Configs['goals']['fitbit']['steps']
      if steps_today <= threshold
	"FAIL: need #{threshold - steps_today} more steps to pass!"
      else
	"PASS: over by #{steps_today - threshold} steps, good job!"
      end
    end

  end
end
