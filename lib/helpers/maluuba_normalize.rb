class MaluubaNormalize
  extend Cogibara::Lang::Normalize

  requires 'maluuba_napi'
  # requires_key 'maluuba'
  requires_key 'maluuba_timezone'

  def self.rdf_class
    "NormalizedTime"
  end

  def self.process(message)
    if message.is_a? Cogibara::Message
      h = normalize_string message.message
      if h[:entities][:time]
        prop = message.new_property
        add_type(prop)
        prop << [RDF.type, onto_class[rdf_class]]
        prop << [onto_prop.normalized_time, h[:entities][:time].first]

        message << prop

        prop
      else
        nil
      end
    else
      h = normalize_string message.to_s
      h[:entities][:time].first if h[:entities][:time]
    end
  end

  def self.normalize_string(str)
    client = MaluubaNapi::Client.new(nil)

    h = client.normalize phrase: str, type: "time", timezone: settings["keys"]["maluuba_time"]
  end

  Cogibara::Lang::Normalize.register(:maluuba, self)
end