class DBPediaSpotlight < Cogibara::Module
  extend Cogibara::Lang::NER

  requires 'dbpedia/spotlight'

  def self.spotlight_structures(msg)
    spotlight = DBpedia::Spotlight("http://spotlight.dbpedia.org/rest/")
    entities = spotlight.annotate(msg.message)
    if entities
      # puts "#{entities}"
      entities.select{|e| e["@surfaceForm"]}.each_with_index.map do |ent,i|
        new_prop = msg.new_property
        new_prop << [RDF.type, onto_class.SpotlightEntity]
        new_prop << [onto_prop.spotlight_entity_uri, ent["@URI"]]
        new_prop << [onto_prop.spotlight_types, ent["@types"]]
        new_prop << [onto_prop.spotlight_support_score, ent["@support"]]
        new_prop << [onto_prop.spotlight_surface_form, ent["@surfaceForm"]]
        new_prop
      end
    end
  end

  def self.rdf_class
    "SpotlightEntity"
  end

  def self.process(message)
    struct = spotlight_structures(message)
    struct.each{|st| message << st} if struct
    struct
  end

  Cogibara::Lang::NER.register(:spotlight, self)

  # on(/.*spotlight entities for "(.+)"$/) do |message, msg|
  #   structs = spotlight_structures(msg)
  #   structs.map{|st| st.values}.join(', ')
  # end

  # on(/.*spotlight (URIs|annotations) for "(.+)"$/i) do |message, annot, msg|
  #   structs = spotlight_structures(msg)
  #   if structs
  #     Hash[structs.map{|st| [st.values["spotlight_surface_form"], st.values["spotlight_entity_uri"]]}].to_s
  #   else
  #     "Couldn't find any spotlight annotations for #{msg}"
  #   end
  # end

  # on do

  #   struct = spotlight_structures(message.message)
  #   struct.each{|st| message << st} if struct
  #   message
  # end

  # register :classify
end