module Cogibara
  class Instance
    def memory
      @memory ||= Memory.new
    end

    def memory=(repo)
      @memory.repo = repo
    end

    def ask(message)
      ModuleStack.stack.each do |mod|
        puts "asking #{mod}" if Cogibara::Module::settings["debug"]
        catch(:mod_pass) do
          begin
            response = mod.ask(message) {|y| yield y }
            if response.is_a? String
              response = memory.new_message(response)
              response_details(message, response)
              return response
            elsif response.is_a? Symbol
              raise "received code #{response} from #{mod}"
            elsif response.is_a? Cogibara::Message
              # for now, just pass along message objects
              # puts "pass along messages or return new ones"
            else
              # for now, just pass along messages with unknown returns
              # puts "unknown return type #{response.class} from #{mod.class}" if
            end
          rescue Exception => e
            # puts "error occured in module #{mod}\n#{e.backtrace}" if Cogibara::Module::settings["debug"]
            response = memory.new_message("error occured in module #{mod}")
            response_details(message, "error occured in module #{mod}")
            raise e if Cogibara.settings["debug"]
            return response
          end
        end
      end

      raise "Didnt know what to say for #{message}, #{ModuleStack.stack}"
    end

    def response_details(message, response)
      message.response = response
      response.from = "http://cogi.strinz.me/users/cogibara"
      response.to = message.from
      message.save
      response.save
    end
  end
end
