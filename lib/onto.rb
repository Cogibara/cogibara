class Cogibara
  module Onto
    def onto_class
      RDF::Vocabulary.new 'http://onto.cogibara.com/classes/'
    end

    def onto_prop
      RDF::Vocabulary.new 'http://onto.cogibara.com/properties/'
    end
  end
end