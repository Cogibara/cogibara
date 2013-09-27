class Cogibara
  class UserQuestion
    attr_accessor :question
    attr_accessor :response

    def initialize(question=nil)
      @question = question if question
    end
  end
end