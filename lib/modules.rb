
# require 'cleverbot'

class Chatbot < Cogibara::Module
  requires 'cleverbot'

  def ask(message)
    @cleverbot ||= Cleverbot::Client.new
    @cleverbot.write message.message
  end
end

class Maluuba < Cogibara::Module
  requires 'maluuba_napi'

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
end

class DiceRoller < Cogibara::Module
  on(/^roll (\d+)d(\d+)/) do |number,size|
    number.to_i.times.map{|t| rand(size.to_i)+1 }.join("\n")
  end

end

Maluuba.register :classify
Chatbot.register
DiceRoller.register :last