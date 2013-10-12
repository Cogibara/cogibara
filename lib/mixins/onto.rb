module Cogibara
  module Onto
    class << self
      PREFIXES = {
        rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
      }

      def prefix_for(uri)
        uri = uri.to_s
        pre = PREFIXES.find{|k,v| uri[/^#{v}/]}
        if pre
          pre[0].to_s
        else
          nil
        end
      end
    end

    def onto_class
      RDF::Vocabulary.new 'http://onto.cogibara.com/classes/'
    end

    def onto_prop
      RDF::Vocabulary.new 'http://onto.cogibara.com/properties/'
    end
  end
end