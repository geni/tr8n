module Tr8n
  class Engine < ::Rails::Engine
    isolate_namespace Tr8n
    config.autoload_paths << root.join('lib')

    def self.mount_point
      return nil unless defined?(Rails) && Rails.application
      @mount_point ||=  begin
        route = Rails.application.routes.routes.find {|ii| ii.app.respond_to?(:app) && ii.app.app == self}
        path = route.path.spec.to_s
        path.gsub(/\([^)]*\)/, '').chomp('/')
      end
    end

    #
    # initializer blocks are excecuted during boot (order can vary)
    #
    initializer 'tr8n.load_core_extensions' do |app|
      Dir["#{Engine.root}/lib/core_ext/**/*.rb"].each do |file|
        require file
      end
    end

    #
    # to_prepare blocks are executed after all classes are loaded
    #
    config.to_prepare do
      ::ApplicationController.include Tr8n::Concerns::ControllerMethods

      WillFilter.configure do |config|
        config.table_name_prefix = 'wf' unless Rails.env.test?
      end
    end

  end # class Engine
end # module Tr8n
