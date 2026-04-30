$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tr8n/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tr8n"
  s.version     = Tr8n::VERSION
  s.authors     = ["Michael Berkovich"]
  s.email       = ["michael@geni.com"]
  s.homepage    = "https://github.com/berk/tr8n"
  s.summary     = "Crowd-sourced translation and localization for Rails"
  s.description = "Crowd-sourced translation and localization for Rails"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.22.5"

  s.add_development_dependency "sqlite3"
end
