module Cogibara
  class Message
    extend Cogibara::Onto
    include Cogibara::Onto

    class RDFMsg < Spira::Base
      extend Cogibara::Onto

      configure base_uri: 'http://cogi.strinz.me/messages/'

      property :message, predicate: onto_prop.message_string
      property :response, predicate: onto_prop.response, type: RDF::URI
      property :from, predicate: onto_prop.from_user, type: RDF::URI
      property :to, predicate: onto_prop.to_user, type: RDF::URI
      property :message_id, predicate: onto_prop.message_id

      has_many :topics, predicate: onto_prop.message_topic
      has_many :structured_properties, predicate: onto_prop.has_structured_property, type: RDF::URI

    end

    class StructuredProperty

      def initialize(uri,vals)
        @uri = uri
        @values = vals

        values.keys.each{|k|
          k = "type" if k == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
          define_singleton_method(k.to_sym) do
            self[k]
          end
        }
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

      def save(repo)
        @values.map{|val|
          # puts "#{[RDF::URI(@uri),val[0],val[1]]}"
          repo << [RDF::URI(@uri),val[0],val[1]]
        }
      end

      def [](prop)
        values[prop]
      end
    end


    def self.where(conditions = {})
      conditions = Hash[conditions.map{|k,v|
        if k.is_a? Symbol
          [onto_prop[k.to_s], v]
        else
          [RDF::URI(k.to_s), v]
        end
      }]

      query = RDF::Query.new(result: conditions)
      solutions = query.execute(repo)

      solutions.map{|sol| Message.for(sol[:result]) }
    end

    def self.repo
      Spira.repositories[RDFMsg.configure[:reposity_name] || :default]
    end

    def repo
      Message.repo
      # Spira.repositories[@msg.class.configure[:reposity_name] || :default]
    end

    def num_structs
      @tmp_structs ||= rdf_msg.structured_properties.size
    end

    def new_property(values=[])
      index = num_structs + 1
      @tmp_structs += 1
      values << [onto_prop.attached_to_message, rdf_msg.subject]
      StructuredProperty.new("#{rdf_msg.subject.to_s}/structured_properties/#{index}", values)
    end

    def struct_properties(prop_class=nil)
      if prop_class
        m = rdf_msg
        has_prop = onto_prop.has_structured_property
        cl = onto_class[prop_class]
        props = RDF::Query.execute(repo) do
          pattern [m.subject, has_prop, :o]
          pattern [:o, RDF.type, cl]
        end

        props = props.map{|prop| prop[:o] }

        props.map{|prop| property_for(prop)}
      else
        rdf_msg.structured_properties.map{|prop| property_for(prop)}
      end
    end

    def property_for(property_uri)

      props = RDF::Query.execute(repo) do
        pattern [property_uri, :p, :o]
      end

      props = props.map{|prop|
        [prop[:p], prop[:o]]
      }

      StructuredProperty.new(property_uri, props)
    end

    def <<(prop)
      unless prop.is_a? StructuredProperty
        raise "Can only append Structured_Property instances at the moment (tried #{prop.class})"
      end
      rdf_msg.structured_properties << RDF::URI(prop.subject)
      rdf_msg.save
      prop.save(repo)
    end

    def response_to
      s = self
      solutions = RDF::Query.execute(repo) do
        pattern [:original, s.onto_prop.response, s.rdf_msg.subject]
      end

      if solutions.size == 0
        nil
      else
        Message.for(solutions.first[:original])
      end
    end

    def to_s
      rdf_msg.subject.to_s
    end

    def self.for(uri)
      self.new(uri)
    end

    def temp
      @temp ||= {}
    end

    def initialize(uri)
      @msg = RDFMsg.for(uri)
    end

    def rdf_msg
      @msg
    end

    def response
      Message.for(rdf_msg.response)
    end

    def respond_to?(meth)
      (methods | @msg.methods).include? meth
    end

    def set(property, value)
      value = value.to_s if value.is_a? Symbol
      repo.insert([@msg.subject, RDF::URI.new(property), value])
    end

    def get(property)
      s = self
      solutions = RDF::Query.execute(repo) do
        pattern [s.rdf_msg.subject, RDF::URI.new(property), :value]
      end

      sols = solutions.map{|sol| sol[:value].object}
      if sols.size == 0
        nil
      elsif sols.size == 1
        sols.first
      else
        sols
      end
    end

    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^set_/
        set(onto_prop[meth.to_s.gsub(/^set_/,'')], *args, &block)
      elsif meth.to_s =~ /^get_/
        get(onto_prop[meth.to_s.gsub(/^get_/,'')], *args, &block)
      elsif @msg.respond_to? meth
        if args.size >0
          @msg.send meth, *args, &block
        else
          @msg.send meth, &block
        end
      else
        super(meth, *args, &block)
      end
    end
  end
end