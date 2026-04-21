# Dual-boot compatible boot file for Rails 3.1 and 3.2
# Configure your app in config/environment.rb and config/environments/*.rb

RAILS_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(RAILS_ROOT)

# Detect if we're running under next_rails (Rails 3.2)
def rails_3_2?
  ENV['BUNDLE_GEMFILE'] && ENV['BUNDLE_GEMFILE'].include?('.next')
end

# Bundler setup MUST come first to load correct gem versions
# Don't auto-require tr8n yet
require 'bundler/setup'
Bundler.setup(:default, :test) rescue Bundler.setup(:default)

# Patch Rails for Ruby 2.7 compatibility after install
if rails_3_2?
  `ruby #{RAILS_ROOT}/script/patch_rails_3_2_for_ruby_27.rb`
else
  `ruby #{RAILS_ROOT}/script/patch_rails_3_1_for_ruby_27.rb`
end

# Load BigDecimal compatibility fix BEFORE Rails (must come before ActiveSupport)
# Rails 3.2's ActiveSupport tries to call BigDecimal.new which was deprecated in Ruby 2.7
if rails_3_2? && RUBY_VERSION >= '2.7'
  require 'bigdecimal'
  unless BigDecimal.respond_to?(:new)
    BigDecimal.define_singleton_method(:new) do |*args, **kwargs|
      if kwargs.empty?
        ::Kernel.BigDecimal(*args)
      else
        ::Kernel.BigDecimal(*args, **kwargs)
      end
    end
  end
end

# Rails 3.1 and 3.2 both use the same boot process
# Load individual Rails components (since we're not using the rails meta-gem)
require 'active_support'
require 'active_model'
require 'active_record'
require 'action_pack'
require 'action_mailer'

# Load runtime compatibility fixes for Rails 3.2 + Ruby 2.7
# These must be loaded after Rails is required but before application code runs
# This applies to all environments: production, development, and test
if rails_3_2?
  require File.expand_path('../../lib/core_ext/rails_32_ruby_27_compat', __FILE__)
end

require 'rbconfig'
Config = RbConfig
