class Cogibara
  module Interface
    def ask_string(msg, opts={})
      Cogibara.ask(Cogibara.memory.new_message(msg, opts)){|y| request_input y}
    end

    def ask(msg, opts={})
      ask_string(msg.to_s,opts)
    end

    def request_input(msg)
      puts "#{msg}"
      z = gets
    end

    # def ask_xmpp(msg)

    # end

    # plain string; generate message id
    # def ask_local(string)

    # end
  end
end

class Cogibara::Interface::XMPP
  include Cogibara::Interface

  def ask(msg,opts={})
    msg = ask_string(msg.body, id: msg.id, from: msg.from)
    msg.message
  end
end

class Cogibara::Interface::Local
  include Cogibara::Interface

  def ask(string)
    msg = ask_string(string, from: "local")
    msg.message
  end
end