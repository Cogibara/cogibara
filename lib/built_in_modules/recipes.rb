class Recipes < Cogibara::Module
  requires 'yummly'

  requires_key 'yummly_id'
  requires_key 'yummly_key'

  def initialize
    Yummly.configure do |config|
      config.app_id = settings["keys"]["yummly_id"]
      config.app_key = settings["keys"]["yummly_key"]
    end
  end

  def find_recipe(query)
    recipes = Yummly.search(query)
    recipes = recipes.sort_by{|e| e.rating}.reverse
    unless recipes.first
      say "No Recipes Found"
      pass
    end
    r = Yummly.find(recipes.first.id)
    <<-EOF
Recipe: #{r.name}
Ingredients:
#{r.ingredients.join("\n")}
    EOF
  end

  on(/recipe for (.+)$/i) do |msg, recipe|
    find_recipe(recipe)
  end

  on(:any, wit_intent: 'recipe_search') do |msg|
    # puts current_message.struct_properties.map(&:values)
    # wit_entities = current_message.struct_properties.select{|p| p.values["wit_entity_type"] }.map(&:values)
    # time_entity = wit_entities.select{|e| e["wit_entity_type"] == "reminder_time"}.first
    # message_entity = wit_entities.select{|e| e["wit_entity_type"] == "reminder_text"}.first
    # method_entity = wit_entities.select{|e| e["wit_entity_type"] == "reminder_method"}

    # # puts message_entity
    # if method_entity.size > 0
    #   make_remind(message_entity["wit_entity_value"], time_entity["wit_entity_value"], method_entity.first["wit_entity_value"])
    # else
    #   make_remind(message_entity["wit_entity_value"], time_entity["wit_entity_value"])
    # end

    # "okay, reminding you to #{message_entity["wit_entity_value"]} at #{time_entity['wit_entity_value']}"
  end

  register
end