module Cogibara
  module Skippable
    def requires(*gems)
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

    def requires_key(key)
      unless settings["keys"][key]
        # DaemonKit.logger.info "missing key #{key}, Skipping module #{self}"
        puts "missing key #{key}, Skipping module #{self}"
        @__ignore = true
      end
    end

    def settings
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
  end
end