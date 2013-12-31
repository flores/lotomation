module Lotomation
  module Steps

    client = Fitgem::Client.new(Config['auth']['fitbit'])
    
    def stepstoday()
      data = client.activities_on_date 'today'

      data['summary']['steps']
    end

    def stepsalert(threshold)
      if stepstoday <= threshold
	flip('alarm-on')
	log("FAIL: need #{threshold - stepstoday} more steps to pass!")
      else
	flip('alarm-off')
	log("PASS: over by #{stepstoday - threshold} steps, good job!")
      end
    end

  end
end
