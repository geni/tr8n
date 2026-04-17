# Rails 3.0 boot file
# Configure your app in config/environment.rb and config/environments/*.rb

RAILS_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(RAILS_ROOT)

# Patch Rails 3.0 for Ruby 2.7 compatibility after install
`#{RAILS_ROOT}/script/patch_rails_3_for_ruby_27.sh`

# Load Rails components
require 'active_support'
require 'active_model'
require 'active_record'
require 'action_pack'
require 'action_mailer'

# Bundler setup for Rails 3.0 (but don't auto-require tr8n yet)
if defined?(Bundler)
  # Manually require gems to avoid auto-requiring tr8n
  Bundler.setup(:default, :test) rescue Bundler.setup(:default)
end

require 'rbconfig'
Config = RbConfig
