module Cogibara
  # Change Module to 'Base' or something
  class Module
    extend  Cogibara::Skippable

    def self.register(category=:none)
      #should probably put them on a list that gets loaded to make this more transparent
      # also need multiple categories
      Cogibara::ModuleStack.register self.new, category unless @__ignore
    end

    # def self.requires(*gems)
    #   gems.each{|g|
    #     begin
    #       require g
    #     rescue LoadError
    #       @__ignore = true
    #       puts "missing gem #{g}, Skipping module #{self}"
    #       DaemonKit.logger.info "missing gem #{g}, Skipping module #{self}"
    #     end
    #   }
    # end

    # def self.requires_key(key)
    #   unless settings["keys"][key]
    #     # DaemonKit.logger.info "missing key #{key}, Skipping module #{self}"
    #     puts "missing key #{key}, Skipping module #{self}"
    #     @__ignore = true
    #   end
    # end

    # def self.settings
    #   @@yml ||= nil
    #   unless @@yml
    #     yml_file = File.dirname(__FILE__) + '/../config/cogibara.yml'
    #     if File.exist? yml_file
    #       @@yml = YAML.load_file(yml_file)
    #     else
    #       @@yml = {"keys" => {}}
    #     end
    #   end

    #   @@yml
    # end

    def self.on(pattern=/.*/, restrictions={}, &block)
      if pattern.is_a? Symbol
        case pattern
        when :question
          pattern = /(?:what|who|why|how|where|when).*/i
        when :any
          pattern = /.*/
        else
          raise "Unkown pattern symbol #{pattern}"
        end
      end

      response_patterns << [pattern, [block, restrictions]]
    end

    def self.response_patterns
      @response_patterns ||= []
    end

    def current_message
      @current_message
    end

    # FILTER = Proc.new {|block| v = block.call(current_message) }
    def filter(&block)
      throw :pass unless block.call(current_message)
    end

    def pass
      throw :mod_pass
    end

    def request_input(msg)
      @__yielder.call(Cogibara::UserQuestion.new(msg)).response
    end

    def say(msg)
      @__yielder.call(msg)
    end

    def settings
      self.class.settings
      # unless @yml
      #   yml_file = File.dirname(__FILE__) + '/../config/cogibara.yml'
      #   if File.exist? yml_file
      #     @yml = YAML.load_file(yml_file)
      #   else
      #     @yml = {"keys" => {}}
      #   end
      # end

      # @yml
    end


    def meets_restrictions(message,restrictions={})
      restrictions.each{|k,v|
        return false unless message.send("get_#{k}") == v
      }
    end

    # Override for custom behavior for now
    #  should have this call some other method if defined, so
    #  eg setting up current message still happens

    def ask(message,&block)
      @current_message = message
      # raise "#{Cogibara.dump_memory}"
      @__yielder ||= Proc.new {|y| yield y}
      selected = self.class.response_patterns.select{|patt|
        message.message[patt[0]] &&
        meets_restrictions(message,patt[1][1])
      }

      if selected.size > 0
        selected.each do |sel|
          catch(:pass) do
            if sel[0].is_a? Regexp
              return instance_exec(*[message, message.message.scan(sel[0])].flatten, &sel[1][0]) #{|y| yield y }
            elsif sel[0].is_a? String
              return instance_exec &sel[1][0] #{|y| yield y }
            else
              raise "unknown pattern match type"
            end
          end
        end
      else
        message
      end
    end
  end
end