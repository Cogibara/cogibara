class DBPediaSpotlight < Cogibara::Module
  include Cogibara::Onto

  requires 'dbpedia/spotlight'

  PROPERTIES = {
    leader: "http://dbpedia.org/property/leaderName"
  }

  def spotlight_structures(msg)
    spotlight = DBpedia::Spotlight("http://spotlight.dbpedia.org/rest/")
    entities = spotlight.annotate(msg)
    if entities
      # puts "#{entities}"
      entities.select{|e| e["@surfaceForm"]}.each_with_index.map do |ent,i|
        new_prop = current_message.new_property(i)
        new_prop << [RDF.type, onto_class.SpotlightEntity]
        new_prop << [onto_prop.spotlight_entity_uri, ent["@URI"]]
        new_prop << [onto_prop.spotlight_types, ent["@types"]]
        new_prop << [onto_prop.spotlight_surface_form, ent["@surfaceForm"]]
        new_prop
      end
    end
  end

  on(/.*spotlight entities for "(.+)"$/) do |msg|
    structs = spotlight_structures(msg)
    structs.map{|st| st.values}.join(', ')
  end

  on(/.*spotlight URIs for "(.+)"$/) do |msg|
    structs = spotlight_structures(msg)
    Hash[structs.map{|st| [st.values["spotlight_surface_form"], st.values["spotlight_entity_uri"]]}].to_s
  end

  on do

    struct = spotlight_structures(current_message.message)
    struct.each{|st| current_message << st} if struct
    current_message
  end
  # def lookup_property(property)
  #   if PROPERTIES[property.to_sym]
  #     PROPERTIES[property.to_sym]
  #   else
  #     spq = SPARQL::Client.new("http://dbpedia.org/sparql")
  #     qry = spq.select.where([:s, RDF.type, RDF.Property]).select.where([:s, RDF::RDFS.label, RDF::Literal.new(property, language: :en)])
  #     # puts qry.to_s
  #     sols = qry.execute
  #     # puts sols.map(&:to_hash)
  #     sols.map(&:s).map(&:to_s).first
  #   end
  # end

  # on(/^(who|what) is the (.+) of (.+)/) do |question,property,object|
  #   past_results = Cogibara::Message.where(message_string: current_message.message).select{|msg| msg.get_dbpedia_response }

  #   if past_results.size > 0
  #     past_results.first.response.message
  #   else
  #     prop = lookup_property(property)

  #     sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
  #     object = object.capitalize unless object[0] == object[0].capitalize

  #     qry = sparql.select.distinct.where([:s, RDF::RDFS.label, RDF::Literal.new(object, language: :en)]).select.where([:s, RDF::URI.new(prop),:prop_val])
  #     sols = qry.execute

  #     # puts sols.map(&:to_hash)
  #     if sols.size > 0
  #       results = sols.distinct.map{|sol|
  #         if sol[:prop_val].is_a? RDF::URI
  #           qr2 = sparql.select.where([sol[:prop_val], RDF::RDFS.label, :label]).distinct
  #           sol2 = qr2.execute.filter {|so| so[:label].language == :en}

  #           # puts sol2.map(&:to_hash)
  #           # puts sol.class.to_s

  #           if sol2.size > 0
  #             sol2.first[:label].object
  #           else
  #             current_message
  #           end
  #         else
  #           sol[:prop_val].object.to_s
  #         end
  #       }

  #       current_message.set_dbpedia_response(results.join(', '))

  #       results.join ', '
  #     else
  #       current_message
  #     end
  #   end
  #   # puts sols.map(&:to_hash)

  #   #   sols.map(&:label).map(&:to_s).join ', '
  #   # else
  #   #   current_message
  #   #   # "found #{object_repo.size} statements for #{object}"
  #   # end
  # end

  register :classify
end