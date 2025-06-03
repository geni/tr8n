module Tr8n
  class Engine < ::Rails::Engine
    isolate_namespace Tr8n
    config.autoload_paths << "#{Engine.root}/lib"

    initializer 'tr8n.load_core_extensions' do |app|
      Dir["#{Engine.root}/lib/core_ext/**/*.rb"].each do |file|
        require file
      end
    end

    initializer 'tr8n.include_mixins' do |app|
      ActiveSupport.on_load(:application_controller) do
        ApplicationController.send(:include, Tr8n::CommonMethods)
      end
      ActiveSupport.on_load(:application_helper) do
        ApplicationHelper.send(:include, Tr8n::HelperMethods)
      end
    end

  end # class Engine
end # module Tr8n
