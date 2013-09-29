class Wit < Cogibara::Module
  include Cogibara::Onto
  requires 'httparty'
  requires 'json'
  requires 'cgi'

  requires_key 'wit'

  def entity_hash(json)
    if json["outcome"] && json["outcome"]["entities"]
      json["outcome"]["entities"]
    else
      {}
    end
  end

  def entity_structs(json)
    entity_hash(json).map{|id,info|
      new_prop = current_message.new_property
      new_prop << [RDF.type, onto_class.WitEntity]
      new_prop << [onto_prop.wit_entity_type, id]
      info = info.first if info.is_a? Array
      new_prop << [onto_prop.wit_entity_value, info["value"]]
      new_prop << [onto_prop.wit_entity_start, info["start"]]
      new_prop << [onto_prop.wit_entity_end, info["end"]]
      new_prop << [onto_prop.wit_entity_body, info["body"]]
      new_prop
    }
  end

  on(/wit debug "(.+)"/i) do |msg, message|

    api_key = settings["keys"]["wit"]
    response = HTTParty.get("https://api.wit.ai/message?q=#{CGI::escape message}", headers: {"Authorization" => "Bearer #{api_key}"})

    response.body.to_s
    # JSON.parse(response.body).to_s
  end

  on do
    message = current_message.message
    api_key = settings["keys"]["wit"]

    response = HTTParty.get("https://api.wit.ai/message?q=#{CGI::escape message}", headers: {"Authorization" => "Bearer #{api_key}"})

    js = JSON.parse(response.body)
    current_message.set_wit_intent(js["outcome"]["intent"]) if js["outcome"] and js["outcome"]["intent"]
    entity_structs(js).each{|s| current_message << s}

    pass
  end

  register :classify
end