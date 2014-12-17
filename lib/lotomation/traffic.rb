module Lotomation
  module Traffic

    def traffic(direction)
      data = "traffic-" + direction
      if seconds_since_last_update(data) > 200
        traffic_update(direction)
      else
        check_value(data)
      end
    end

    def traffic_update(direction)
      traffictime = 0
      direction == 'to_work' ? link = Configs['traffic']['home_to_work'] : link = Configs['traffic']['work_to_home']
      results = `curl -sL #{link} |perl -pi -e 's/span/\n/g' |grep traffic |grep 'In current traffic'`

      results.split('\n').each do |line|
        if line =~ /current traffic: (.+)\shour.+(\d+)\smin/
          hours = $1.to_i
          mins = $2.to_i
          traffictime = (hours * 60) + mins
       elsif line =~ /current traffic: (.+)\smin/
          traffictime = $1
        end
      end

      write_value("traffic-" + direction, traffictime)
    end

  end
end
