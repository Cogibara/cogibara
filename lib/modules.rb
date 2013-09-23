
# require 'cleverbot'

class Chatbot < Cogibara::Module
  requires 'cleverbot'

  def ask(message)
    @cleverbot ||= Cleverbot::Client.new
    @cleverbot.write message.message
  end

  register :last
end

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

class DiceRoller < Cogibara::Module
  on(/^roll (\d+)d(\d+)/) do |number,size|
    number.to_i.times.map{|t| rand(size.to_i)+1 }.join("\n")
  end

  register
end