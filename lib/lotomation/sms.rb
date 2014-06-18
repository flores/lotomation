module Lotomation
  module Sms

    def sms_out(message)
      twilio = Twilio::REST::Client.new Configs['auth']['twilio']['sid'], Configs['auth']['twilio']['token']
      twilio.account.messages.create(
        :from => "+1#{Configs['auth']['twilio']['sms_from']}",
        :to => "+1#{Configs['auth']['twilio']['sms_to']}",
        :body => message
      )
    end

    def sms_in(message)
      reply = ""

      message.split(/\s(?:and|then)\s/).each do |body|
        if body =~ /state/i
          reply = all_states
          puts "reply is #{reply}"
        end
        if body =~ /(.+)\s(on|off)/i
          device = $1
          state = $2
          if device =~ /air|(?:^ac$)/i
            device = 'air-conditioner'
            log_historical('hvac', "sms request to switch air-conditioner to #{state}")
            state == 'off' ? write_state('hvac', 'off') : write_state('hvac', device)
          elsif device =~ /heat/i
            device = 'heater'
            log_historical('hvac', "sms request to switch heater to #{state}")
            state == 'off' ? write_state('hvac', 'off') : write_state('hvac', device)
          else
            device='farside-light' if device =~ /far/i
            device='nearside-light' if device =~ /near/i
            device='aquariums' if device =~ /aquarium/i
            device='stereo' if device =~ /stereo/i
            actuate(device, state)
          end
          reply = "turned #{device} to #{state}. #{reply}"
        end
        if body =~ /(?:maintain|temp).+?(\d+)/i
          temp = $1
          log_historical('hvac', "sms request to maintain temp #{temp} via sms")
          write_state('maintain-temp', temp)
          write_state('maintain', 'on')
          reply = "maintaining temperature #{temp}. #{reply}"
        end
      end
      reply = "i do not know what this is, got #{body}" if reply == ""
      return reply
    end

  end
end
