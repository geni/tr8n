lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'tr8n'
  gem.version       = IO.read('VERSION')
  gem.authors       = ['Michael Berkovich']
  gem.email         = ['michael@geni.com']
  gem.description   = %q{Crowd-sourced translation and localization for Rails}
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/berk/tr8n'
  gem.license       = 'MIT'

  # Support both Rails 3.1 and 3.2 for dual-boot compatibility
  # Use individual components to avoid bundler version conflicts
  rails_version = ENV['BUNDLE_GEMFILE'] =~ /\.next/ ? '~> 3.2.0' : '~> 3.1.0'

  gem.add_dependency 'activesupport', rails_version
  gem.add_dependency 'activerecord', rails_version
  gem.add_dependency 'actionpack', rails_version
  gem.add_dependency 'actionmailer', rails_version

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
