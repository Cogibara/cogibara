module Cogibara
  class User
    extend Cogibara::Onto

    class RDFUser < Spira::Base
      extend Cogibara::Onto
      configure base_uri: 'http://cogi.strinz.me/users/'

      property :identifier, predicate: onto_prop.user_id, type: String
      property :name, predicate: RDF::FOAF.name, type: String

      has_many :sent_messages, predicate: onto_prop.has_message
      has_many :received_messages, predicate: onto_prop.has_message
    end

    def rdf_user
      @rdf_user
    end

    def self.for(name)
      # should recognize uris
      new(name)
    end

    def initialize(name)
      @rdf_user = RDFUser.for(encode(name))
      @rdf_user.identifier = name
      @rdf_user.save
    end

    def encode(name)
      CGI::escape(name)
    end

    def method_missing(meth, *args, &block)
      if rdf_user.respond_to? meth
        if args.size >0
          rdf_user.send meth, *args, &block
        else
          rdf_user.send meth, &block
        end
      else
        super(meth, *args, &block)
      end
    end
  end
end