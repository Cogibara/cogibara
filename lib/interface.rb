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

module Cogibara
  module Interface
    class XMPP
      include Cogibara::Interface

      def ask(msg)
        msg = ask_string(msg.body, id: msg.id, from: msg.from.to_s)
        msg.message
      end

      def reply(msg)
        raise "XMPP can't reply yet"
      end
      
      def intermediate_response(msg)
        raise "XMPP can't reply yet"
      end
    end
  end
end

module Cogibara
  module Interface
    class Local
      include Cogibara::Interface

      def ask(string)
        msg = ask_string(string, from: "local")
        msg.message
      end
    end
  end
end

module Cogibara
  module Interface
    class GVoice
      include Cogibara::Interface

      def ask(msg_json)
        response = ask_string(msg_json["message"], from: msg_json["phoneNumber"])
        response
      end
    end
  end
end

module Cogibara
  module Interface
    class Speech
      include Cogibara::Interface

      # eventually move audio processing to here?
      def ask(str)
        ask_string(str, from: 'local-speech').message
      end
    end
  end
end