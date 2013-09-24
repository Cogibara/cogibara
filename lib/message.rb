class Cogibara
  class Message
    extend Cogibara::Onto
    include Cogibara::Onto

    class RDFMsg < Spira::Base
      extend Cogibara::Onto

      configure base_uri: 'http://cogi.strinz.me/messages/'

      property :message, predicate: onto_prop.message_string
      property :response, predicate: onto_prop.response, type: RDF::URI
      property :from, predicate: onto_prop.from_user, type: String
      property :to, predicate: onto_prop.to_user, type: String
      property :message_id, predicate: onto_prop.message_id

      has_many :topics, predicate: onto_prop.message_topic

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