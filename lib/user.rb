class User
  extend Cogibara::Onto

  class RDFUser < Spira::Base
    extend Cogibara::Onto
    configure base_uri: 'http://cogi.strinz.me/users/'

    property :identifier, predicate: onto_prop.from_user, type: String
    property :name, predicate: RDF::FOAF.name, type: String
    has_many :messages, predicate: onto_prop.has_message
  end

  def rdf_user
    @rdf_user
  end

  def method_missing(meth, *args, &block)
    elsif rdf_user.respond_to? meth
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