require 'pp'

module Tr8n
  # Define base modules first to avoid NameError with plain require
  module Tokens
    # This module will contain all token types
  end

  # Get the gem root directory
  gem_root = File.expand_path('../../..', __FILE__)

  # Require external gem dependencies first
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
        # Skip version.rb and engine.rb to avoid circular loading
        next if file.end_with?('base_filter.rb') ||
                file.end_with?('version.rb') ||
                file.end_with?('engine.rb')
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

  # Extend models with ActiveDumper (deferred to avoid loading order issues)
  def self.extend_models_with_active_dumper
    if defined?(Tr8n::Config) && defined?(Tr8n::ActiveDumper)
      Tr8n::Config.models.each do |model|
        model.extend(Tr8n::ActiveDumper) rescue nil
      end
    end
  end

  # Rails Engine definition (only when Rails is loaded)
  if defined?(Rails)
    class Engine < ::Rails::Engine
      isolate_namespace Tr8n

      # Rails 3.0+ initialization hook
      initializer "tr8n.configure_rails_initialization" do
        # Extend models with ActiveDumper now that everything is loaded
        Tr8n.extend_models_with_active_dumper

        ActiveSupport.on_load(:action_controller) do
          include Tr8n::CommonMethods
        end

        ActiveSupport.on_load(:action_view) do
          include Tr8n::HelperMethods
        end
      end
    end
  end
end
