# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.


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

require_relative 'onto.rb'

require_relative 'base_module.rb'
require_relative 'class_methods.rb'
# require_relative 'instance_methods.rb'
require_relative 'interface.rb'
require_relative 'memory.rb'
require_relative 'message.rb'
require_relative 'modules.rb'