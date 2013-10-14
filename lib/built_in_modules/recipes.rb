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

  def find_recipes(query)
    recipes = Yummly.search(query)
    recipes = recipes.sort_by{|e| e.rating}.reverse
    unless recipes.first
      say "No Recipes Found"
      pass
    end
    @recipes = recipes
  end

  def select_recipe(index=0, criterion = :rating)
    r = @recipes.sort_by{|r| r.send(criterion)}.reverse
    unless r[index]
      say "No more recipes"
      pass
    end
    r = Yummly.find(r[index].id)
    <<-EOF
Recipe: #{r.name}
Ingredients:
#{r.ingredients.join("\n")}
    EOF
  end

  on(/recipe for (.+)$/i) do |msg, recipe|
    find_recipes(recipe)
    @recipe_index = 0
    select_recipe 0
  end

  on "next recipe" do
    pass unless @recipe_index
    @recipe_index += 1
    select_recipe(@recipe_index)
  end

  on(:any, wit_intent: 'recipe_lookup') do |msg|
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
    "Wit based recipe finding not implemented"
    # "okay, reminding you to #{message_entity["wit_entity_value"]} at #{time_entity['wit_entity_value']}"
  end

  register
end