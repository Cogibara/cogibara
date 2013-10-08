class WitNER
  extend Cogibara::Lang::NER

  requires 'httparty'
  requires 'json'
  requires 'cgi'

  requires_key 'wit'

  def self.rdf_class
    "WitEntity"
  end

  def self.process(message)
    api_key = settings["keys"]["wit"]

    response = HTTParty.get("https://api.wit.ai/message?q=#{CGI::escape message.message}", headers: {"Authorization" => "Bearer #{api_key}"})

    js = JSON.parse(response.body)
    message.set_wit_intent(js["outcome"]["intent"]) if js["outcome"] and js["outcome"]["intent"]
    ents = entity_structs(js, message)
    ents.each{|s| message << s}

    ents
  end

  def self.entity_hash(json)
    if json["outcome"] && json["outcome"]["entities"]
      json["outcome"]["entities"]
    else
      {}
    end
  end

  def self.entity_structs(json, message)
    # puts "json: #{json}, h: #{entity_hash(json)}" if json.to_s["remind"]
    entity_hash(json).map{|id,info|
      new_prop = message.new_property
      new_prop << [RDF.type, onto_class.WitEntity]
      add_type(new_prop)
      new_prop << [onto_prop.wit_entity_type, id]
      info = info.first if info.is_a? Array
      new_prop << [onto_prop.wit_entity_value, info["value"]]
      new_prop << [onto_prop.wit_entity_start, info["start"]]
      new_prop << [onto_prop.wit_entity_end, info["end"]]
      new_prop << [onto_prop.wit_entity_body, info["body"]]
      new_prop
    }
  end
  
  Cogibara::Lang::NER.register(:wit, self)
end