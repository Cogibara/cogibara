class Cogibara
  def modules
    @modules ||= []
  end

  def memory
    @memory ||= Memory.new
  end

  def ask(message)

    modules.each do |mod|
      response = mod.ask(message)
      if response.is_a? String
        response = memory.new_message(response)
        response_details(message, response)
        return response
      elsif response.is_a? Symbol
        raise "received code #{response} from #{mod}"
      elsif response.is_a? Cogibara::Message
        puts "pass along messages or return new ones"
      end
    end
  end

  def response_details(message, response)
    message.response = response
    response.from = "cogibara"
    response.to = message.from
    message.save
    response.save
  end
end