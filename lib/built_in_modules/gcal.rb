class Gcal < Cogibara::Module
  requires 'google_calendar'
  requires 'time'

  requires_key 'google_name'
  requires_key 'google_pass'

  def make_remind(message, time = Time.now.to_s, methods = ['alert'])
    @cal ||= Google::Calendar.new(:username => "#{settings["keys"]["google_name"]}",
      :password => settings["keys"]["google_pass"],
      :app_name => 'cogibara.com-gcal-integration')

    time = Time.parse(time)
    methods = Array(methods)

    event = @cal.create_event do |e|
      e.title = message
      e.start_time = time + (60 * 10)
      e.end_time = time + (60 * 60) # seconds * min
      methods.map{|m|
        e.reminders << {method: m, minutes: 1}
      }
    end
  end


  on(/^remind me to (.*) at (.*)(am|pm)/i) do |msg, reminder, time, day_night|
    make_remind(reminder, time + " " + day_night)
    t = " tonight" if day_night == "pm"
    "okay, reminding you to #{reminder} at #{time}#{t}"
  end

  on(/^remind me via (\w+) to (.*) at (.*)(am|pm)/i) do |msg, method, reminder, time, day_night|
    make_remind(reminder, time + " " + day_night, method)
    t = " tonight" if day_night == "pm"
    "okay, reminding you to #{reminder} at #{time}#{t}"
  end

  register
end