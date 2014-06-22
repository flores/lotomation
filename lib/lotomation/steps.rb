module Lotomation
  module Steps

    Fit = Fitgem::Client.new(Configs['auth']['fitbit'])

    def steps_today()
      if seconds_since_last_update('steps') > 600
        data = Fit.activities_on_date 'today'
        data['summary'] ? steps = data['summary']['steps'] : steps = 0

        write_value('steps', steps)
        steps
      else
        check_value('steps')
      end
    end

    def steps_goal()
      Configs['goals']['fitbit']['steps']
    end

    def steps_today_percent
      steps_today.to_i*100/steps_goal
    end

    def distances_today()
      data = Fit.activities_on_date 'today'
      data['summary']['distances']
    end

    def steps_alert()
      threshold = Configs['goals']['fitbit']['steps']
      steps = steps_today.to_i
      if steps == 0
        "Unknown steps -- FitBit API down"
      elsif steps <= threshold
        "FAIL: need #{threshold - steps} more steps to pass!"
      else
        "PASS: over by #{steps - threshold} steps, good job!"
      end
    end

    def steps_punishments()
      Configs['punishments']
    end

    def steps_punishments_enforce()
      triggered = 0
      now = DateTime.now.hour

      steps_punishments.each do |goalhour,pain|
        if now >= goalhour  && lo_home?
          message = steps_alert
          if message =~ /FAIL/
            if seconds_since_last_update("sms-punishment-sent-#{goalhour}") >= 900
              write_value("sms-punishment-sent-#{goalhour}", 'yes')
              sms_out("Oh snap son, turning #{pain['devices'].join(' ')} #{pain['state']}. #{message}")
            end
            if check_state('locator') == 'on'
              write_state('locator', 'off')
            end
            pain['devices'].each {|device| actuate(device, pain['state'])}
          end
        end
      end
    end

  end
end
