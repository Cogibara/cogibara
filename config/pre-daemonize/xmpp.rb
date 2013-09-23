begin
  require 'blather'
rescue LoadError
  $stderr.puts "Missing blather gem. Please run 'bundle install'."
  exit 1
end

BASE_DIR = File.absolute_path(File.dirname(__FILE__) + '/../..')
# puts `cd ../../wonderland.lit && vines start -d`