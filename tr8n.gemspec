require_relative 'lib/tr8n/version'

Gem::Specification.new do |gem|
  gem.name          = 'tr8n'
  gem.version       = Tr8n::VERSION
  gem.authors       = ['Michael Berkovich', 'Scott Steadman']
  gem.email         = ['michael@geni.com', 'scott.steadman@geni.com']
  gem.homepage      = 'https://github.com/geni/tr8n'
  gem.summary       = gem.description
  gem.description   = %q{Crowd-sourced translation and localization for Rails}
  gem.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  gem.metadata["allowed_push_host"] = 'none'

  gem.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  gem.add_dependency 'rails', '~> 8.0.0'
  gem.add_dependency 'sprockets-rails'
end
