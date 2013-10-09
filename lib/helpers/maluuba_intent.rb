class MaluubaIntent
  extend Cogibara::Lang::Intent

  requires 'maluuba_napi'
  requires_key 'maluuba'

  def self.rdf_class
    "MaluubaIntent"
  end

  def self.process(message)
    api_key = settings["keys"]["wit"]

    client = MaluubaNapi::Client.new(nil)
    # response = HTTParty.get("https://api.wit.ai/message?q=#{CGI::escape message.message}", headers: {"Authorization" => "Bearer #{api_key}"})
    
    h = client.interpret phrase: message.message
    # msg.set_maluuba_category(h[:category])
    # msg.set_maluuba_action(h[:action])
    # js = JSON.parse(response.body)
    [:action, :category].map do |cat|
      message.send(:"set_maluuba_#{cat}", h[cat]) 
      prop = message.new_property
      add_type(prop)
      prop << [RDF.type, onto_class[rdf_class]]
      prop << [onto_prop.intent, h[cat].to_s]
      
      message << prop

      prop
    end
  end

  Cogibara::Lang::Intent.register(:maluuba, self)
end