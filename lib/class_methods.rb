class Cogibara


    def self.dump_memory
      memory.dump_memory
    end

    def self.memory
      @@memory ||= base_cogi.memory
    end

    def self.base_cogi
      @@base_cogi ||= Cogibara.new
    end

    def self.ask(message)
      base_cogi.ask(message)
    end

    def self.load_base_modules
      ::Chatbot.register

      # require_relative 'modules.rb'
    end

end