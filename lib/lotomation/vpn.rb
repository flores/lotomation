module Lotomation
  module Vpn

    def vpn_up?
      result = system("ping -c 2 -t 1 #{Configs['vpn']['ip_home']}")
      result == 0 ? true : false
    end

  end
end
