# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.

require 'yaml'
require 'tempfile'

require_relative 'onto.rb'

require_relative 'base_module.rb'
require_relative 'class_methods.rb'
require_relative 'instance_methods.rb'
require_relative 'interface.rb'
require_relative 'memory.rb'
require_relative 'message.rb'
require_relative 'module_stack.rb'

require_relative 'built_in_modules/modules.rb'
require_relative 'built_in_modules/dbpedia_query.rb'
require_relative 'built_in_modules/dbpedia_spotlight.rb'