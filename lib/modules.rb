class Chatbot < Cogibara::Module
  require 'cleverbot'
  def ask(message)
    @cleverbot ||= Cleverbot::Client.new
    @cleverbot.write message.message
  end

  register
end