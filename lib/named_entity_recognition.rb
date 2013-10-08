module Cogibara
  module Lang
    module NER
      include Cogibara::Skippable
      include Cogibara::Onto

      class << self
        def register(sym, klass)
          registry[sym] = klass
        end

        def for(sym)
          registry[sym]
        end

        def get_entities(msg)
          registry.values.map{|recognizer| recognizer.get_entities(msg)}.flatten
        end

        def registry
          (@registry ||= {})
        end
      end

      def process(msg)
        raise "should override"
      end

      def rdf_class
        raise "should override"
      end

      def get_entities(msg)
        cached = check_memory(msg)
        if cached.size > 0
          cached
        else
          process(msg)
        end
      end

      def check_memory(msg)
        msg.struct_properties(rdf_class)
      end

      def add_type(property)
        property << [RDF.type, onto_class.NamedEntity]
      end
    end
  end
end