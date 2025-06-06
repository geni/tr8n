# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'pp'

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'

  config.action_controller.session = {
    :session_key => '_tr8n_session',
    :secret => '09ae61ae208e3df7066ff7d514533fcd'
  }

  config.rails_lts_options = { :default => :compatible}
end
