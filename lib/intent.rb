module Cogibara
  module Lang
    module Intent
      include Cogibara::Skippable
      include Cogibara::Onto

      class << self
        def register(sym, klass)
          registry[sym] = klass
        end

        def for(sym)
          registry[sym]
        end

        def get_intent(msg)
          registry.values.map{|recognizer| recognizer.get_intent(msg)}.flatten
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

      def get_intent(msg)
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
        property << [RDF.type, onto_class.Intent]
      end
    end
  end
end