
# require 'cleverbot'

class Chatbot < Cogibara::Module
  requires 'cleverbot'

  def ask(message)
    @cleverbot ||= Cleverbot::Client.new
    @cleverbot.write message.message
  end

  register :last
end

class Maluuba < Cogibara::Module
  requires 'maluuba_napi'
  requires 'gist'

  def initialize
    @client ||= MaluubaNapi::Client.new(@api_key)
  end

  on(/^maluuba/) do
    @client.interpret(phrase: current_message.message.gsub(/^maluuba/,'')).to_s
  end

  on do
    h = @client.interpret phrase: current_message.message
    current_message.set_maluuba_category(h[:category])
    current_message.set_maluuba_action(h[:action])
  end

  register :classify
end

class MemoryDumper < Cogibara::Module
  on(/^dump memory to gist/) do
    g = Gist.gist(Cogibara.dump_memory, filename: 'memory.ttl')
    g["html_url"]
  end

  on(/^dump memory/) do
    Cogibara.dump_memory
  end

  register
end

class DiceRoller < Cogibara::Module
  on(/^roll (\d+)d(\d+)/) do |number,size|
    number.to_i.times.map{|t| rand(size.to_i)+1 }.join("\n")
  end

  register
end

class DBPediaQuery < Cogibara::Module
  requires 'sparql/client'

  PROPERTIES = {
    leader: "http://dbpedia.org/property/leaderName"
  }
  on(/^(who|what) is the (\w+) of (\w+)/) do |question,property,object|
    # object_repo = RDF::Repository.load("http://dbpedia.org/data/#{object.capitalize}.ttl")
    require 'sparql/client'
    sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
    prop = PROPERTIES[property.to_s.to_sym]
    qry = sparql.select.where([:s, RDF::RDFS.label, RDF::Literal.new(object.capitalize, language: :en)]).select.where([:s, RDF::URI.new(prop),:prop_val]).select.where([:prop_val,RDF::RDFS.label,:label])
    sols = qry.each_solution.to_a
    if sols.size > 0
      sols.map(&:label).map(&:to_s).join ', '
    else
      current_message
      # "found #{object_repo.size} statements for #{object}"
    end
  end

  register
end