class Cogibara
  class ModuleStack

    def self.known_categories
      [:classify, :pre, :none, :last]
    end

    def self.register(klass,category=:none)
      category = :none unless known_categories.include? category
      modules[category].unshift(klass)
      # Cogibara.base_cogi.modules
    end

    def self.modules
      @modules ||= known_categories.each_with_object({}) { |cat, h| h[cat] = [] }
    end

    def self.stack
      known_categories.map{|cat| modules[cat] }.flatten
    end

    def self.clear
      newc = known_categories.each_with_object({}) { |cat, h| h[cat] = [] }
      @modules = newc
    end
  end
end