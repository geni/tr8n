# Rails 3.0+ application configuration
# This file is only loaded when running under Rails 3.0+

require File.expand_path('../boot', __FILE__)

# For a gem, we don't need a full Rails::Application for testing
# Just establish database connection directly

# Establish database connection for testing if config exists
if File.exist?(File.expand_path('../database.yml', __FILE__))
  # Pre-require sqlite3 to avoid version constraint issues with Rails 3.2
  # Rails 3.2 expects sqlite3 ~> 1.3.5, but we're using 1.6.9
  require 'sqlite3'

  # Monkey-patch Kernel#gem to bypass sqlite3 version check for Rails 3.2
  # This allows us to use sqlite3 1.6.9 with Rails 3.2 which expects 1.3.5
  original_gem = Kernel.method(:gem)
  Kernel.define_method(:gem) do |name, *requirements|
    if name == 'sqlite3'
      # Skip the version check for sqlite3
      return
    end
    original_gem.call(name, *requirements)
  end

  require 'yaml'
  db_config = YAML.load_file(File.expand_path('../database.yml', __FILE__))
  ActiveRecord::Base.establish_connection(db_config[ENV['RAILS_ENV'] || 'test'])
end
