# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.

require 'yaml'
require 'tempfile'
require 'cgi'

require 'rdf/turtle'
require 'spira'

# require 'daemon_kit'

Dir["#{File.dirname(__FILE__)}/mixins/*.rb"].each {|file| require file }

require_relative 'base_module.rb'
require_relative 'class_methods.rb'
require_relative 'instance_methods.rb'
require_relative 'interface.rb'
require_relative 'memory.rb'
require_relative 'user.rb'
require_relative 'message.rb'
require_relative 'user_question.rb'
require_relative 'module_stack.rb'

require_relative 'built_in_modules/modules.rb'

Dir["#{File.dirname(__FILE__)}/lang/*.rb"].each {|file| require file }

Dir["#{File.dirname(__FILE__)}/built_in_modules/*.rb"].each {|file| require file }
Dir["#{File.dirname(__FILE__)}/interfaces/*.rb"].each {|file| require file }
Dir["#{File.dirname(__FILE__)}/helpers/*.rb"].each {|file| require file }

Spira.add_repository(:default,Cogibara.memory.repo)


# require_relative 'built_in_modules/dbpedia_query.rb'
# require_relative 'built_in_modules/dbpedia_spotlight.rb'
# require_relative 'built_in_modules/wit.rb'
# require_relative 'built_in_modules/evernote.rb'