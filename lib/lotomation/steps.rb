module Lotomation
  module Steps

    def stepstoday()
      client = Fitgem::Client.new(Config['auth']['fitbit'])
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
