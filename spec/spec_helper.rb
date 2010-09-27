# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

EphemeralResponse.configure do |config|
  config.fixture_directory = "spec/fixtures/responses"
  config.expiration        = 86400
  config.skip_expiration   = true
  config.white_list        = 'localhost'

  config.register(URI.parse(Moip::CONFIG["uri"]).host) do |request|
    "#{request.uri.host}#{request.method}#{request.path}"
  end  
end

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.mock_with :mocha
end