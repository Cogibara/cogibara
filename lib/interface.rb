class Cogibara
  class Interface
    def ask(msg,opts={})
      Cogibara.ask Cogibara.memory.new_message(msg, opts)
    end

    def ask_xmpp(msg)
      msg = ask msg.body, id: msg.id, from: msg.from
      msg.message
    end

    # plain string; generate message id
    def ask_local(string)
      msg = ask(string, from: "local")
      msg.message
    end
  end
end