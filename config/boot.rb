# Dual-boot compatible boot file for Rails 3.0 and 3.1
# Configure your app in config/environment.rb and config/environments/*.rb

RAILS_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(RAILS_ROOT)

# Detect if we're running under next_rails (Rails 3.1)
def rails_3_1?
  ENV['BUNDLE_GEMFILE'] && ENV['BUNDLE_GEMFILE'].include?('.next')
end

# Rails 3.0 and 3.1 both use the same boot process
# Load individual Rails components (since we're not using the rails meta-gem)

# Patch Rails for Ruby 2.7 compatibility after install
if rails_3_1?
  `ruby #{RAILS_ROOT}/script/patch_rails_3_1_for_ruby_27.rb`
else
  `#{RAILS_ROOT}/script/patch_rails_3_for_ruby_27.sh`
end

require 'active_support'
require 'active_model'
require 'active_record'
require 'action_pack'
require 'action_mailer'

# Bundler setup for Rails 3.0/3.1 (but don't auto-require tr8n yet)
if defined?(Bundler)
  # Manually require gems to avoid auto-requiring tr8n
  Bundler.setup(:default, :test) rescue Bundler.setup(:default)
end

require 'rbconfig'
Config = RbConfig
