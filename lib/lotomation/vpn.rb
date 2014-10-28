module Lotomation
  module Vpn

    def vpn_response_time
      ping=`ping -c 2 -w 1 #{Configs['vpn']['ip_home']} |tail -1`.strip!
      if ping =~ /^rtt min.+\/(.+?)\//
        $1 + "ms"
      else
        "down"
      end
    end

    def openvpn_server(command)
      if command =~ /^(start|stop|restart)$/
        system("/etc/init.d/openvpn #{command}") ? "#{command}ed" : "fail"
      else
        "unrecognized command"
      end
    end
  end
end
