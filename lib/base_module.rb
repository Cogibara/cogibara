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

    # TODO should make sure this is registered as a block, so "return" will override
    # ask's return behavior?
    def self.on(pattern=/.*/,&block)
      response_patterns << [pattern, block]
    end

    def self.response_patterns
      @response_patterns ||= []
    end

    def current_message
      @current_message
    end

    def pass
      :pass
    end

    def settings
      @yml ||= YAML.load_file(File.dirname(__FILE__) + '/../config/cogibara.yml')
    end

    # Override for custom behavior for now
    #  should have this call some other method if defined, so
    #  eg setting up current message still happens

    def ask(message)
      @current_message = message
      selected = self.class.response_patterns.select{|patt| message.message[patt[0]]}
      if selected.size > 0
        selected = selected.first
        if selected[0].is_a? Regexp
          instance_exec(*message.message.scan(selected[0]).flatten, &selected[1])
        elsif selected[0].is_a? String
          instance_exec &selected[1]
        else
          raise "unknown pattern match type"
        end
      else
        message
      end
    end
  end
end