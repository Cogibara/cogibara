class Gcal < Cogibara::Module
  requires 'google_calendar'
  requires 'time'
  requires 'chronic'

  requires_key 'google_name'
  requires_key 'google_pass'

  def parse_time(t)
    time = Chronic.parse t
    if time
      time
    else
      interm = current_message.normalize
      if interm && interm.first && interm.first["normalized_time"]
        Chronic.parse interm.first["normalized_time"]
      else
        nil
      end
    end
  end

  def make_remind(message, time = Time.now.to_s, methods = ['sms'])
    raise "Missing reminder parameter" unless message and time and methods

    @cal ||= Google::Calendar.new(:username => "#{settings["keys"]["google_name"]}",
      :password => settings["keys"]["google_pass"],
      :app_name => 'cogibara.com-gcal-integration')

    puts "#{time.class}, #{time}" if settings["debug"]
    methods = Array(methods)
    puts "#{message}"  if settings["debug"]
    puts "#{methods}" if settings["debug"]
    event = @cal.create_event do |e|
      e.title = message
      e.start_time = time + 60
      e.end_time = time + 60 # seconds * min
      methods.map{|m|
        e.reminders << {method: m, minutes: 1}
      }
    end
  end


  on(/^remind me to (.*) at (.*)(am|pm)/i) do |msg, reminder, time, day_night|
    make_remind(reminder, parse_time(time + " " + day_night))
    t = " tonight" if day_night == "pm"
    "okay, reminding you to #{reminder} at #{time}#{t}"
  end

  on(/^remind me via (\w+) to (.*) at (.*)(am|pm)/i) do |msg, method, reminder, time, day_night|
    make_remind(reminder, parse_time(time + " " + day_night), method)
    t = " tonight" if day_night == "pm"
    "okay, reminding you to #{reminder} at #{time}#{t}"
  end

  on(:any, wit_intent: 'set_reminder') do |msg|
    # puts current_message.struct_properties.map(&:values)
    wit_entities = current_message.struct_properties("WitEntity")
    time_entity = wit_entities.select{|e| e.wit_entity_type == "reminder_time"}.first
    message_entity = wit_entities.select{|e| e.wit_entity_type == "reminder_text"}.first
    method_entity = wit_entities.select{|e| e.wit_entity_type == "reminder_method"}

    time = parse_time(time_entity.wit_entity_value)
    unless time
      "couldn't understand time '#{time_entity.wit_entity_value}', no reminder set"
    else
      # puts message_entity
      if method_entity.size > 0
        make_remind(message_entity.wit_entity_value, time, method_entity.first.wit_entity_value)
      else
        make_remind(message_entity["wit_entity_value"], time)
      end

      "okay, reminding you to #{message_entity["wit_entity_value"]} at #{time}"
    end
  end

  register
end