module Lotomation
  module Traffic

    def traffic(direction)
      file = "#{Configs['status']['dir']}/traffic-#{direction}"
      if File.exist?(file)
        if (Time.now - File.mtime(file)) > 200
          print "file is #{Time.now - File.mtime(file)} seconds old"
          traffic_update(direction)
        else
          File.read(file)
        end
      else
        traffic_update(direction)
      end
    end
   
    def traffic_update(direction)
      traffictime = ''
      direction == 'to_work' ? link = Configs['traffic']['home_to_work'] : link = Configs['traffic']['work_to_home']
      results = `curl -sL #{link} |perl -pi -e 's/span/\n/g' |grep traffic |grep 'In current traffic'`

      results.split('\n').each do |line|
        if line =~ /current traffic: (.+)?\s\</
          traffictime == '' ? traffictime = $1 : traffictime = "#{traffictime} - $1"
        end
      end

      File.write("#{Configs['status']['dir']}/traffic-#{direction}", traffictime)
      traffictime
    end
    
  end
end
