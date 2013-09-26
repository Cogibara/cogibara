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
        # {?prop a rdf:Property}
        # UNION
        # {?prop a owl:ObjectProperty}

        ?prop rdfs:label ?prop_label.

        FILTER regex(str(?prop_label), "#{property}$", "i")
        {
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
        UNION
        {
          <#{subject}> ?prop ?label .
          FILTER isURI(?label)
          MINUS { ?label rdfs:label ?lab}
        }
      }
      EOF


      # qry = spq.select.where([:s, RDF.type, RDF.Property]).select.where([:s, RDF::RDFS.label, RDF::Literal.new(property, language: :en)])
      # puts qry.to_s
      sols = spq.query(qry)
      # puts sols.to_s
      # sols = qry.execute
      # puts sols.map(&:to_hash)
      sols.map(&:label).map(&:to_s)
    end
  end

  def properties_for(subject)
    spq = SPARQL::Client.new("http://dbpedia.org/sparql")
    qry = <<-EOF
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX owl: <http://www.w3.org/2002/07/owl#>


    SELECT DISTINCT ?pred ?label WHERE {
     # {?pred a rdf:Property}
     # UNION
     # {?pred a owl:ObjectProperty}

     <#{subject}> ?pred [].

     ?pred rdfs:label ?label
     FILTER(LANG(?label) = "" || LANGMATCHES(LANG(?label), "en"))
   }
   EOF

   sols = spq.query(qry)
   sols.map(&:label).map(&:object)
  end

  def dbpedia_uri_for(object, use_spotlight=false)
    # puts current_message.struct_properties.map(&:values)
    # sparql = SPARQL::Client.new(Cogibara.memory.repo)

    spotlight_results = current_message.struct_properties.select{|p| p.values["spotlight_surface_form"] == object}

    if use_spotlight && spotlight_results.size > 0
      puts "#{[{s: spotlight_results.first.values["spotlight_entity_uri"]}]}"
      [{s: spotlight_results.first.values["spotlight_entity_uri"]}]
    else
    # qry = <<-EOF
    # PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    # PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    # PREFIX owl: <http://www.w3.org/2002/07/owl#>
    # PREFIX prop: <http://onto.cogibara.com/properties/>
    # PREFIX cogi-class: <http://onto.cogibara.com/classes/>

    # SELECT DISTINCT ?s WHERE {
    #   ?s a cogi-class:Message ;
    #   prop:has_structured_property [
    #     a cogi_class:SpotlightEntity ;
    #     prop:spotlight_surface_form ""
    #   ]
    # }
    # EOF


      sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
      # qry = <<-EOF
      # PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      # PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      # PREFIX owl: <http://www.w3.org/2002/07/owl#>

      # SELECT DISTINCT ?s WHERE {
      #   # {?s a owl:Thing}
      #   # UNION
      #   # {?s a owl:ObjectProperty}

      #   ?s rdfs:label ?prop_label.

      #   FILTER regex(str(?prop_label), "^#{object}$", "i")
      # }
      # EOF
      # puts qry
      qry = sparql.select.distinct.where([:s, RDF::RDFS.label, RDF::Literal.new(object, language: :en)]) #.select.where(*Array(prop).map{|pro| [:s,RDF::URI.new(pro),:prop_val]})
      sparql.query(qry)
    end
  end

  def dbpedia_predicates(object)
    if object == "it"
      object = @it if @it
    else
      @it = object
    end
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

  def dbpedia_fact_question(object,property)
    if object == "it"
      object = @it if @it
    else
      @it = object
    end
    past_results = Cogibara::Message.where(message_string: current_message.message).select{|msg| msg.get_dbpedia_response }

    if past_results.size > 0
      past_results.first.response.message
    else
      sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
      object = object.capitalize unless object[0] == object[0].capitalize

      sols = dbpedia_uri_for(object)

      property = PROPERTIES[property.to_sym] if PROPERTIES[property.to_sym]

      prop = lookup_property(sols.first[:s], property) if sols.size > 0

      if prop && prop.size > 0
        Array(prop).join(', ')
      else
        current_message
      end
    end
  end



  on(/.*(?:what|who|why|how|where|when).*/, wit_intent: "interrogate_knowledge") do
    api_key = settings["keys"]["wit"]
    response = HTTParty.get("https://api.wit.ai/message?q=#{CGI::escape current_message.message}", headers: {"Authorization" => "Bearer #{api_key}"})

    response.body.to_s

    data = JSON.parse(response.body)

    # puts "#{data["outcome"]["entities"]}"
    filter do |msg|
      data["outcome"]["entities"] && data["outcome"]["entities"]["subject"]
    end

    dbpedia_predicates data["outcome"]["entities"]["subject"]["value"]
  end

  on(/what do you know about (.+?)(?:\?|$)/i) do |object|
    # object = object.gsub("?",'')
    dbpedia_predicates object
  end

  on(/what can you tell me about (.+?)(?:\?|$)/i) do |object|
    # object = object.gsub("?",'')
    dbpedia_predicates object
  end

  on(/^(who|what) (?:is|are) the (.+) of (.+?)(?:\?|$)/i) do |question,property,object|
    dbpedia_fact_question object, property
  end

  on(/^(who|what) (?:is|are) the (.+) of (.+?)(?:\?|$)/i) do |question,property,object|
    dbpedia_fact_question object, property
  end

  on(/.*(?:what|who|why|how|where|when).*/, wit_intent: "fact_question") do
    api_key = settings["keys"]["wit"]
    response = HTTParty.get("https://api.wit.ai/message?q=#{CGI::escape current_message.message}", headers: {"Authorization" => "Bearer #{api_key}"})

    response.body.to_s

    data = JSON.parse(response.body)

    # puts "#{data["outcome"]["entities"]}"
    filter do |msg|
      data["outcome"]["entities"] && data["outcome"]["entities"]["subject"] && data["outcome"]["entities"]["fact_property"]
    end

    dbpedia_fact_question data["outcome"]["entities"]["subject"]["value"], data["outcome"]["entities"]["fact_property"]["value"]
  end

  on(/(?:who|what) (is|are)(?: a | an | )(.+?)(?:\?|$)/) do |plural,object|
      if current_message.get_wit_intent
        filter do |m|
          m.get_wit_intent == "summarize_knowledge"
        end
      end
      # object = object.singularize
      if object == "it"
        object = @it if @it
      else
        @it = object
      end

      sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
      object = object.capitalize unless object[0] == object[0].capitalize
      qry = sparql.select.distinct.where([:s, RDF::RDFS.label, RDF::Literal.new(object, language: :en)]) #.select.where(*Array(prop).map{|pro| [:s,RDF::URI.new(pro),:prop_val]})
      # puts qry.to_s
      sols = qry.execute

      if sols.size == 0
        object = object.singularize
        if object == "it"
          object = @it if @it
        else
          @it = object
        end

        object = object.capitalize unless object[0] == object[0].capitalize
        qry = sparql.select.distinct.where([:s, RDF::RDFS.label, RDF::Literal.new(object, language: :en)]) #.select.where(*Array(prop).map{|pro| [:s,RDF::URI.new(pro),:prop_val]})
        sols = qry.execute
      end

      if sols.size > 0
        qry = <<-EOF
        PREFIX dbpedia-owl: <http://dbpedia.org/ontology/>
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX owl: <http://www.w3.org/2002/07/owl#>


        SELECT DISTINCT ?summary WHERE {
          {
            <#{sols.first[:s].to_s}> dbpedia-owl:abstract ?summary.
          }
          UNION
          {
            <#{sols.first[:s].to_s}> dbpedia-owl:wikiPageDisambiguates
            [
              rdfs:label ?summary;
              dbpedia-owl:abstract []
            ]
          }

          FILTER(LANG(?summary) = "" || LANGMATCHES(LANG(?summary), "en"))
        }
        EOF

        # puts qry
        results = sparql.query(qry).map(&:summary).map(&:to_s)
        if results.size > 0
          results.join(', ')
        else
          current_message
        end
      else
        current_message
      end
    end

  register
end