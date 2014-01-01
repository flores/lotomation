module Lotomation
  module Steps

    Fit = Fitgem::Client.new(Configs['auth']['fitbit'])
    
    def stepstoday()
      data = Fit.activities_on_date 'today'

      data['summary']['steps']
    end

    def stepsalert()
      threshold = Configs['goals']['fitbit']['steps']
      if stepstoday <= threshold
	actuate_all('on')
	log("FAIL: need #{threshold - stepstoday} more steps to pass!")
      else
	actuate_all('off')
	log("PASS: over by #{stepstoday - threshold} steps, good job!")
      end
    end

  end
end
