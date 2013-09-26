
# require 'cleverbot'



class Maluuba < Cogibara::Module
  requires 'maluuba_napi'
  requires 'gist'

  def initialize
    @client ||= MaluubaNapi::Client.new(@api_key)
  end

  on(/^maluuba/) do
    @client.interpret(phrase: current_message.message.gsub(/^maluuba/,'')).to_s
  end

  on do
    h = @client.interpret phrase: current_message.message
    current_message.set_maluuba_category(h[:category])
    current_message.set_maluuba_action(h[:action])
  end

  register :classify
end

class MemoryDumper < Cogibara::Module
  on(/^dump memory to gist/) do
    g = Gist.gist(Cogibara.dump_memory, filename: 'memory.ttl')
    g["html_url"]
  end

  on(/^dump memory/) do
    Cogibara.dump_memory
  end

  register
end

class Helper < Cogibara::Module
  def help_text
    "helping you helpfully"
  end

  on(/.*/, maluuba_action: 'HELP_HELP') do
    help_text
  end

  on(/.*/, wit_intent: 'help') do
    help_text
  end

  register
end

class Default < Cogibara::Module
  on do
    if current_message.get_wit_intent
      "I think you want to #{current_message.get_wit_intent}, but I don't know how. try asking for help"
    else
      "I don't know how to respond to that, try asking for help if you're not sure what to do"
    end
  end

  register :last
end

class Chatbot < Cogibara::Module
  requires 'cleverbot'

  def chat(message)
    @cleverbot ||= Cleverbot::Client.new
    @cleverbot.write message.message
  end

  on(/.*/) do
    filter do |msg|
      msg.get_wit_intent == nil || msg.get_wit_intent == "chat" || msg.get_wit_intent == "hello"
    end

    chat(current_message)
  end

  register :last
end

class DiceRoller < Cogibara::Module
  on(/^roll (\d+)d(\d+)/) do |message, number, size|
    number.to_i.times.map{|t| rand(size.to_i)+1 }.join("\n")
  end

  register
end