class Cogibara
  # Change Module to 'Base' or something
  class Module
    def self.register(category=:none)
      #should probably put them on a list that gets loaded to make this more transparent
      # also need multiple categories
      Cogibara::ModuleStack.register self.new, category unless @__ignore
    end

    def self.requires(*gems)
      gems.each{|g|
        begin
          require g
        rescue LoadError
          @__ignore = true
          puts "missing gem #{g}, Skipping module #{self}"
          DaemonKit.logger.info "missing gem #{g}, Skipping module #{self}"
        end
      }
    end

    def self.requires_key(key)
      unless settings["keys"][key]
        DaemonKit.logger.info "missing key #{key}, Skipping module #{self}"
        @__ignore = true
      end
    end

    def self.settings
      @@yml ||= nil
      unless @@yml
        yml_file = File.dirname(__FILE__) + '/../config/cogibara.yml'
        if File.exist? yml_file
          @@yml = YAML.load_file(yml_file)
        else
          @@yml = {"keys" => {}}
        end
      end

      @@yml
    end

    # TODO should make sure this is registered as a proc if it isnt already, so "return" will override
    # ask's return behavior?
    def self.on(pattern=/.*/, restrictions={}, &block)
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

    def settings
      unless @yml
        yml_file = File.dirname(__FILE__) + '/../config/cogibara.yml'
        if File.exist? yml_file
          @yml = YAML.load_file(yml_file)
        else
          @yml = {"keys" => {}}
        end
      end

      @yml
    end


    def meets_restrictions(message,restrictions={})
      restrictions.each{|k,v|
        return false unless message.send("get_#{k}") == v
      }
    end

    # Override for custom behavior for now
    #  should have this call some other method if defined, so
    #  eg setting up current message still happens

    def ask(message)
      @current_message = message
      # @filter ||= Proc.new {|block| v = block.call(current_message); return unless v }
      selected = self.class.response_patterns.select{|patt| message.message[patt[0]] && meets_restrictions(message,patt[1][1])}

      if selected.size > 0
        selected.each do |sel|
          catch(:pass) do
            if sel[0].is_a? Regexp
              return instance_exec(*[message, message.message.scan(sel[0])].flatten, &sel[1][0])
            elsif sel[0].is_a? String
              return instance_exec &sel[1][0]
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