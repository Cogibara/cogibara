class Wit < Cogibara::Module
  requires 'httparty'
  requires 'json'
  requires 'cgi'

  requires_key 'wit'

  on(/wit debug "(.+)"/i) do |message|

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

    pass
  end

  register :classify
end