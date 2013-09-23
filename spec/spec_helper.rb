# require 'simplecov'
# SimpleCov.start

DAEMON_ENV = 'test' unless defined?( DAEMON_ENV )

begin
  require 'rspec'
rescue LoadError
  require 'rubygems'
  require 'rspec'
end

require File.dirname(__FILE__) + '/../config/environment'
DaemonKit::Application.running!

RSpec.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

def test_values(object, expected_values)
  expected_values.each do |attribute, value|
    object[attribute].should == value
  end
end