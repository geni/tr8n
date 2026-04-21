# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'pp'

# Rails 3.0 and 3.1 initialization (both use the same process)
require File.expand_path('../application', __FILE__)

# Load Tr8n gem explicitly
require File.expand_path('../../lib/tr8n', __FILE__)
