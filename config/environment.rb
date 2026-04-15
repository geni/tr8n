# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'pp'

# Detect Rails version
def rails_3?
  ENV['BUNDLE_GEMFILE'] && ENV['BUNDLE_GEMFILE'].include?('.next')
end

if rails_3?
  # Rails 3.0+ initialization
  require File.expand_path('../application', __FILE__)

  # Load Tr8n gem explicitly
  require File.expand_path('../../lib/tr8n', __FILE__)

  # Initialize the test application
  if defined?(Tr8nTest::Application)
    Tr8nTest::Application.initialize!
  end
else
  # Rails 2.3 initialization
  Rails::Initializer.run do |config|
    config.time_zone = 'UTC'

    config.action_controller.session = {
      :session_key => '_tr8n_session',
      :secret => '09ae61ae208e3df7066ff7d514533fcd'
    }

    config.rails_lts_options = { :default => :compatible}
  end
end
