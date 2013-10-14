module Cogibara

  class << self
    def dump_memory
      memory.dump_memory
    end

    def memory
      @@memory ||= base_cogi.memory
    end

    def base_cogi
      @@base_cogi ||= Cogibara::Instance.new
    end

    def ask(message)
      base_cogi.ask(message) {|y| yield y}
    end

    def load_base_modules
      ::Chatbot.register :last
      ::Maluuba.register :classify
      ::MemoryDumper.register
      ::DiceRoller.register
      ::DBPediaQuery.register

      # require_relative 'modules.rb'
    end

    def export_memory(file='brain.ttl')
      open(file,'w'){|f| f.write(dump_memory)}
    end

    def import_memory(file)
      base_cogi.memory = RDF::Repository.load(file)
    end

    def settings
      unless @@yml ||= nil
        yml_file = File.dirname(__FILE__) + '/../config/cogibara.yml'
        if File.exist? yml_file
          @@yml = YAML.load_file(yml_file)
        else
          @@yml = {"keys" => {}}
        end
      end

      @@yml
    end

  end
end