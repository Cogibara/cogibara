# Update this Gemfile with any additional dependencies and run
# 'bundle install' to get them all installed. Daemon-kit's capistrano
# deployment will ensure that the bundle required by your daemon is properly
# installed.
#
# For more information on bundler, please visit http://gembundler.com

source 'https://rubygems.org'

# Live on the edge instead: gem 'daemon-kit', :github => 'kennethkalmer/daemon-kit'
gem 'daemon-kit', :github => 'kennethkalmer/daemon-kit'
# gem 'daemon-kit', git: 'https://github.com/wstrinz/daemon-kit.git'

#
# safely (http://github.com/kennethkalmer/safely)
#

gem 'safely' # Optional, but recommended.

# gem 'toadhopper' # For reporting exceptions to hoptoad
# gem 'mail' # For reporting exceptions via mail

gem 'blather', git: 'https://github.com/adhearsion/blather.git', branch: 'develop' #, '~> 0.8.7'
group :development, :test do
  gem 'rake'
  gem 'rspec'
end

group :test do
  gem 'vcr'
  gem 'webmock', '~> 1.11.0'
  gem 'simplecov'
end
# gem 'vines', git: 'https://github.com/negativecode/vines.git'

gem 'rdf'
gem 'rdf-turtle'
gem 'spira'

# ## SQLite based persistence (some trouble with daemonizing)

# gem 'rdf-do'
# gem 'do_sqlite3'

## XMPP Server

gem 'vines', "~> 0.4.7"
gem 'vines-web'

## COGIBARA GEMS
gem 'cleverbot', :require => false
gem 'maluuba_napi', :require => false, git: 'https://github.com/wstrinz/napi-ruby.git'
gem 'gist', :require => false
gem 'sparql-client', :require => false