module Cogibara
  class Message
    class StructuredProperty

      def initialize(uri,vals)
        @uri = uri
        @values = vals

        define_methods
        # values.keys.each{|k|
        #   k = "type" if k == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"

        #   define_singleton_method(k.to_sym) do
        #     self[k]
        #   end
        # }
      end

      def subject
        @uri
      end

      def <<(values)
        @values << values
      end

      def values
        Hash[@values.map{|v| [v[0].to_s.gsub('http://onto.cogibara.com/properties/',''), v[1].to_s]}]
      end

      def uri_to_method(uri)
        suffix = uri.to_s.split("/").last.split("#").last
      end

      def define_methods
        values.keys.each{|k|
          m = k
          m = uri_to_method(k) if RDF::Resource(k).valid?

          define_singleton_method(m.to_sym) do
            self[k]
          end
        }
      end

      def save(repo)
        define_methods
        @values.map{|val|
          # puts "#{[RDF::URI(@uri),val[0],val[1]]}"
          repo << [RDF::URI(@uri),val[0],val[1]]
        }
      end

      def [](prop)
        values[prop]
      end
    end
  end
end