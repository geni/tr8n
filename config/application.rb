# Rails 3.0+ application configuration
# This file is only loaded when running under Rails 3.0+

require File.expand_path('../boot', __FILE__)

# For a gem, we don't need a full Rails::Application
# Just configure Rails directly
if defined?(Rails)
  # Configure Rails for testing
  if defined?(Rails.application) && Rails.application.nil?
    # Create a minimal application for testing
    module Tr8nTest
      class Application < Rails::Application
        config.encoding = "utf-8"
        config.time_zone = 'UTC'
        config.filter_parameters += [:password]
        config.session_store :cookie_store, :key => '_tr8n_session'
        config.secret_token = '09ae61ae208e3df7066ff7d514533fcd'

        # Disable some Rails 3.0 features not needed for gem testing
        config.active_support.deprecation = :log

        # Database configuration for testing
        config.paths['config/database'] = 'config/database.yml'
      end
    end
  end

  # Establish database connection for testing if config exists
  if File.exist?(File.expand_path('../database.yml', __FILE__))
    require 'yaml'
    db_config = YAML.load_file(File.expand_path('../database.yml', __FILE__))
    ActiveRecord::Base.establish_connection(db_config[ENV['RAILS_ENV'] || 'test'])
  end
end
