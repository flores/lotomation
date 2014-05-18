module Lotomation
  module Traffic

    def traffic
      file = "#{Configs['status']['dir']}/traffic"
      if File.exist?(file)
        if (Time.now - File.mtime(file)) > 200
          print "file is #{Time.now - File.mtime(file)} seconds old"
          traffic_update
        else
          File.read(file)
        end
      else
        traffic_update
      end
    end
   
    def traffic_update
      traffictime = ''
      results = `curl -sL #{Configs['traffic']['link']} |perl -pi -e 's/span/\n/g' |grep traffic |grep 'In current traffic'`

      results.split('\n').each do |line|
        if line =~ /current traffic: (.+)?\s\</
          traffictime == '' ? traffictime = $1 : traffictime = "#{traffictime} - $1"
        end
      end

      File.write("#{Configs['status']['dir']}/traffic", traffictime)
      traffictime
    end
    
  end
end
