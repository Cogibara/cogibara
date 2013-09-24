class DBPediaQuery < Cogibara::Module
  requires 'sparql/client'

  PROPERTIES = {
    leader: "leader name"
  }

  def lookup_property(subject, property)
    if PROPERTIES[property.to_sym]
      PROPERTIES[property.to_sym]
    else
      spq = SPARQL::Client.new("http://dbpedia.org/sparql")
      qry = <<-EOF
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

SELECT DISTINCT ?label WHERE {
  {?prop a rdf:Property}
  UNION
  {?prop a owl:ObjectProperty}

  ?prop rdfs:label ?prop_label.

  FILTER regex(str(?prop_label), "#{property}$", "i")

  {
    <#{subject}> ?prop ?label .
    FILTER isLiteral(?label)
  }
  UNION
  {
    <#{subject}> ?prop [ rdfs:label ?label ].
  }
  FILTER(LANG(?label) = "" || LANGMATCHES(LANG(?label), "en"))
}
      EOF


      # qry = spq.select.where([:s, RDF.type, RDF.Property]).select.where([:s, RDF::RDFS.label, RDF::Literal.new(property, language: :en)])
      # puts qry.to_s
      sols = spq.query(qry)
      # puts sols.to_s
      # sols = qry.execute
      # puts sols.map(&:to_hash)
      sols.map(&:label).map(&:object)
    end
  end

  def properties_for(subject)
    spq = SPARQL::Client.new("http://dbpedia.org/sparql")
    qry = <<-EOF
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>


SELECT DISTINCT ?pred ?label WHERE {
  {?pred a rdf:Property}
  UNION
  {?pred a owl:ObjectProperty}

  <#{subject}> ?pred [].

  ?pred rdfs:label ?label
  FILTER(LANG(?label) = "" || LANGMATCHES(LANG(?label), "en"))
}
    EOF

    sols = spq.query(qry)
    sols.map(&:label).map(&:object)
  end

  on(/^what can you tell me about (.+)/i) do |object|
    sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
    object = object.capitalize unless object[0] == object[0].capitalize

    qry = sparql.select.distinct.where([:s, RDF::RDFS.label, RDF::Literal.new(object, language: :en)])
    sols = qry.execute

    if sols.size > 0
      properties_for(sols.first[:s]).join(", ")
    else
      current_message
    end
  end

  on(/^(who|what) is the (.+) of (.+)/i) do |question,property,object|
    object = object.gsub("?",'')
    past_results = Cogibara::Message.where(message_string: current_message.message).select{|msg| msg.get_dbpedia_response }

    if past_results.size > 0
      past_results.first.response.message
    else

      sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
      object = object.capitalize unless object[0] == object[0].capitalize

      qry = sparql.select.distinct.where([:s, RDF::RDFS.label, RDF::Literal.new(object, language: :en)]) #.select.where(*Array(prop).map{|pro| [:s,RDF::URI.new(pro),:prop_val]})
      sols = qry.execute

      property = PROPERTIES[property.to_sym] if PROPERTIES[property.to_sym]

      prop = lookup_property(sols.first[:s], property) if sols.size > 0
      # puts "pro #{prop}"
      # puts sols.map(&:to_hash)
      # if sols.size > 0
      #   results = sols.distinct.map{|sol|
      #     if sol[:prop_val].is_a? RDF::URI
      #       qr2 = sparql.select.where([sol[:prop_val], RDF::RDFS.label, :label]).distinct
      #       sol2 = qr2.execute.filter {|so| so[:label].language == :en}

      #       # puts sol2.map(&:to_hash)
      #       # puts sol.class.to_s

      #       if sol2.size > 0
      #         sol2.first[:label].object
      #       else
      #         current_message
      #       end
      #     else
      #       sol[:prop_val].object.to_s
      #     end
      #   }

      #   current_message.set_dbpedia_response(true)

      #   results.join ', '
      if prop && prop.size > 0
        Array(prop).join(', ')
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