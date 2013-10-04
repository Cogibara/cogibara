module Cogibara
  class Memory

    include Cogibara::Onto

    PREFIXES = {
      prop: "http://onto.cogibara.com/properties/",
      message: 'http://cogi.strinz.me/messages/',
      cogi_class: 'http://onto.cogibara.com/classes/',
    }

    def dump_memory
      RDF::Turtle::Writer.buffer(:prefixes => PREFIXES) do |writer|
        repo.each_statement do |statement|
          writer << statement
        end
      end
      # repo.to_ttl(prefixes: PREFIXES)
    end

    def self.repo
      Cogibara.base_cogi.repo
    end

    def self.new_message(msg,opts={})
      Cogibara.base_cogi.repo.new_message(msg,opts)
    end

    def default_opts
      {
        id: new_id,
      }
    end

    def repo
      # @repo ||= RDF::DataObjects::Repository.new('sqlite3:cogi_brain.db')
      @repo ||= RDF::Repository.new
    end

    def repo=(new_repo)
      # @repo ||= RDF::DataObjects::Repository.new('sqlite3:cogi_brain.db')
      raise 'not a repository' unless new_repo.is_a? RDF::Repository
      @repo = new_repo
      Spira.add_repository(:default,@repo)
    end

    # TODO: move this to the Message class
    def new_message(msg,opts={})
      opts = default_opts.merge(opts)
      msg_uri = RDF::URI.new("http://cogi.strinz.me/messages/#{opts[:id]}")
      mem = repo
      rdf_msg = Cogibara::Message.for(msg_uri)

      mem.insert([msg_uri, RDF.type, onto_class.Message])
      rdf_msg.message = msg
      rdf_msg.message_id = opts[:id] if opts[:id]
      # mem.insert([msg_uri, onto_prop.message_string, msg])
      # mem.insert([msg_uri, onto_prop.message_id, opts[:id]]) if opts[:id]

      if opts[:to]
        u_to = Cogibara::User.new(opts[:to])
        u_to.received_messages << rdf_msg.subject
        rdf_msg.to = u_to.subject
        u_to.save
        # mem.insert([msg_uri, onto_prop.to_user, opts[:to]]) if opts[:to]
      end

      if opts[:from]
        u_from = Cogibara::User.new(opts[:from])
        u_from.sent_messages << rdf_msg.subject
        rdf_msg.from = u_from.subject
        u_from.save
        # mem.insert([msg_uri, onto_prop.from_user, opts[:from]])
      end

      rdf_msg.save

      rdf_msg
    end

    def new_id
      #Maybe use uuid gem eventually?
      # puts "new"
      "#{Time.now.nsec}_#{rand(1000)}"
    end
  end
end