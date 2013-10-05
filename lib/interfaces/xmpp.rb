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