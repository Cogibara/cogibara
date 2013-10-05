module Cogibara
  module Interface
    def ask_string(msg, opts={})
      Cogibara.ask(Cogibara.memory.new_message(msg, opts)){|y|
        # TODO; All replies should probably be Message objects, just give at userquestion as a type
        #     should probably make #rdf_is_a? method or something to simplify that query
        if y.is_a? Cogibara::UserQuestion
          request_input y
        else
          intermediate_response y
        end
      }
    end

    # Maybe change ask to receive, so #reply can be #send?
    def ask(msg, opts={})
      ask_string(msg.to_s,opts)
    end

    def request_input(msg)
      puts "#{msg.question}"
      msg.response = gets
      msg
    end

    def reply(msg)
      puts msg.message.to_s
    end

    def intermediate_response(msg)
      puts msg.to_s
    end
  end
end