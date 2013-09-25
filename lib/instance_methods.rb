class Cogibara
  def memory
    @memory ||= Memory.new
  end

  def memory=(repo)
    @memory.repo = repo
  end

  def ask(message)

    ModuleStack.stack.each do |mod|
      response = mod.ask(message)
      if response.is_a? String
        response = memory.new_message(response)
        response_details(message, response)
        return response
      elsif response.is_a? Symbol
        if response == :pass

        else
          raise "received code #{response} from #{mod}"
        end
      elsif response.is_a? Cogibara::Message
        # puts "pass along messages or return new ones"
      end
    end

    raise "Didnt know what to say for #{message}, #{ModuleStack.stack}"
  end

  def response_details(message, response)
    message.response = response
    response.from = "cogibara"
    response.to = message.from
    message.save
    response.save
  end
end
