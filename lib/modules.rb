
# require 'cleverbot'

class Chatbot < Cogibara::Module
  requires 'cleverbot'

  def ask(message)
    @cleverbot ||= Cleverbot::Client.new
    @cleverbot.write message.message
  end


end

class DiceRoller < Cogibara::Module
  on(/^roll (\d+)d(\d+)/) do |number,size|
    number.to_i.times.map{|t| rand(size.to_i)+1 }.join("\n")
  end

end

Chatbot.register
DiceRoller.register :last