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
      ::Chatbot.register :last
      ::Maluuba.register :classify
      ::MemoryDumper.register
      ::DiceRoller.register
      ::DBPediaQuery.register

      # require_relative 'modules.rb'
    end

    def self.export_memory(file='brain.ttl')
      open(file,'w'){|f| f.write(dump_memory)}
    end

    def self.import_memory(file)
      base_cogi.memory = RDF::Repository.load(file)
    end

end