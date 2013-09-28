module Cogibara
  module Interface
    def ask_string(msg, opts={})
      Cogibara.ask(Cogibara.memory.new_message(msg, opts)){|y|
        if y.is_a? Cogibara::UserQuestion
          request_input y
        else
          intermediate_response y
        end
      }
    end

    def ask(msg, opts={})
      ask_string(msg.to_s,opts)
    end

    def request_input(msg)
      puts "#{msg.question}"
      msg.response = gets
      msg
    end

    def intermediate_response(msg)
      puts msg.to_s
    end

    # def ask_xmpp(msg)

    # end

    # plain string; generate message id
    # def ask_local(string)

    # end
  end
end

module Cogibara
  module Interface
    class XMPP
      include Cogibara::Interface

      def ask(msg)
        msg = ask_string(msg.body, id: msg.id, from: msg.from)
        msg.message
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
    class Speech
      include Cogibara::Interface
    end
  end
end