module Tr8n
  class Engine < ::Rails::Engine
    isolate_namespace Tr8n
    config.autoload_paths << "#{Engine.root}/lib"

    # excecuted during boot (order can vary)
    initializer 'tr8n.load_core_extensions' do |app|
      Dir["#{Engine.root}/lib/core_ext/**/*.rb"].each do |file|
        require file
      end
    end

    # executed after all classes are loaded
    config.to_prepare do
      ::ApplicationController.include Tr8n::Concerns::ControllerMethods
    end

  end # class Engine
end # module Tr8n
