module Cogibara
  module Interface
    class Local
      include Cogibara::Interface

      def ask(string)
        msg = ask_string(string, from: "local")
        msg.message
      end

      def cycle
        puts ask(gets)
      end
    end
  end
end