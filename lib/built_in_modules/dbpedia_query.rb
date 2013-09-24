class DBPediaQuery < Cogibara::Module
  requires 'sparql/client'

  PROPERTIES = {
    leader: "http://dbpedia.org/property/leaderName"
  }

  def lookup_property(property)
    if PROPERTIES[property.to_sym]
      PROPERTIES[property.to_sym]
    else
      spq = SPARQL::Client.new("http://dbpedia.org/sparql")
      qry = spq.select.where([:s, RDF.type, RDF.Property]).select.where([:s, RDF::RDFS.label, RDF::Literal.new(property, language: :en)])
      # puts qry.to_s
      sols = qry.execute
      # puts sols.map(&:to_hash)
      sols.map(&:s).map(&:to_s).first
    end
  end

  on(/^(who|what) is the (.+) of (.+)/) do |question,property,object|
    past_results = Cogibara::Message.where(message_string: current_message.message).select{|msg| msg.get_dbpedia_response }

    if past_results.size > 0
      past_results.first.response.message
    else
      prop = lookup_property(property)

      sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
      object = object.capitalize unless object[0] == object[0].capitalize

      qry = sparql.select.distinct.where([:s, RDF::RDFS.label, RDF::Literal.new(object, language: :en)]).select.where([:s, RDF::URI.new(prop),:prop_val])
      sols = qry.execute

      # puts sols.map(&:to_hash)
      if sols.size > 0
        results = sols.distinct.map{|sol|
          if sol[:prop_val].is_a? RDF::URI
            qr2 = sparql.select.where([sol[:prop_val], RDF::RDFS.label, :label]).distinct
            sol2 = qr2.execute.filter {|so| so[:label].language == :en}

            # puts sol2.map(&:to_hash)
            # puts sol.class.to_s

            if sol2.size > 0
              sol2.first[:label].object
            else
              current_message
            end
          else
            sol[:prop_val].object.to_s
          end
        }

        current_message.set_dbpedia_response(true)

        results.join ', '
      else
        current_message
      end
    end
    # puts sols.map(&:to_hash)

    #   sols.map(&:label).map(&:to_s).join ', '
    # else
    #   current_message
    #   # "found #{object_repo.size} statements for #{object}"
    # end
  end

  register
end