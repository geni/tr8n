# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'pp'

# Rails 3.0 initialization
require File.expand_path('../application', __FILE__)

# Load Tr8n gem explicitly
require File.expand_path('../../lib/tr8n', __FILE__)

# Initialize the test application
if defined?(Tr8nTest::Application)
  Tr8nTest::Application.initialize!
end

# Establish database connection for Rails 3.0
if File.exist?(File.expand_path('../database.yml', __FILE__))
  require 'yaml'
  db_config = YAML.load_file(File.expand_path('../database.yml', __FILE__))
  ActiveRecord::Base.establish_connection(db_config[ENV['RAILS_ENV'] || 'test'])
end
