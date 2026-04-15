#--
# Copyright (c) 2026 MyHeritage USA, Inc. and MyHeritage Ltd.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

# Main Tr8n gem entry point for Rails 3.0+
# For Rails 2.3, init.rb is used instead

require 'pp'

# Define base modules first to avoid NameError with plain require
module Tr8n
  module Tokens
    # This module will contain all token types
  end

  # Base class for filters
  class BaseFilter
  end

  # Base classes for rules and metrics will be loaded from files
end

# Get the gem root directory
gem_root = File.expand_path('../..', __FILE__)

# Require external gem dependencies first (needed for Rails 3.0+)
begin
  require 'will_filter'
rescue LoadError
  # will_filter not available, some features may not work
end

# Load files using Rails 3.0 compatible approach
# Note: skip filters directory as it requires will_filter gem to be fully initialized
# Load in two passes to handle dependencies
files_to_load = []

["#{gem_root}/lib/core_ext/**",
 "#{gem_root}/lib/tr8n",
 "#{gem_root}/lib/tr8n/tokens",
 "#{gem_root}/app/models/tr8n",
 # "#{gem_root}/app/models/tr8n/filters",  # Skip - requires will_filter
 "#{gem_root}/app/models/tr8n/metrics",
 "#{gem_root}/app/models/tr8n/rules",
 "#{gem_root}/app/models/tr8n/test",
 "#{gem_root}/app/models/tr8n/rules/ext"].each do |dir|
    Dir["#{dir}/*.rb"].sort.each do |file|
      # Skip base_filter.rb as it depends on will_filter
      next if file.end_with?('base_filter.rb')
      files_to_load << file
    end
end

# First pass: try to load all files
files_to_load.each do |file|
  begin
    require file
  rescue NameError => e
    # Dependency not loaded yet, will try again
  end
end

# Second pass: load any files that failed in first pass
files_to_load.each do |file|
  begin
    require file
  rescue NameError => e
    # Still can't load, skip it
    puts "Warning: Could not load #{file}: #{e.message}" if ENV['VERBOSE']
  end
end

# Extend models with ActiveDumper
if defined?(Tr8n::Config)
  Tr8n::Config.models.each do |model|
    model.extend(Tr8n::ActiveDumper)
  end
end

# Rails 3.0+ initialization hook
if defined?(Rails) && defined?(Rails::VERSION) && Rails::VERSION::MAJOR >= 3
  require 'rails'

  class Tr8nRailtie < Rails::Railtie
    initializer "tr8n.configure_rails_initialization" do
      ActiveSupport.on_load(:action_controller) do
        include Tr8n::CommonMethods
      end

      ActiveSupport.on_load(:action_view) do
        include Tr8n::HelperMethods
      end
    end
  end
end
