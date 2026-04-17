source 'http://www.rubygems.org'

# Override Rails components to Rails 3.1 before gemspec is evaluated
gem 'activesupport', '~> 3.1.0'
gem 'activerecord', '~> 3.1.0'
gem 'actionpack', '~> 3.1.0'
gem 'actionmailer', '~> 3.1.0'

gemspec

# Use Rails 3.1 compatible branch of will_filter (override its internal rails dependency)
gem 'will_filter', :git => 'https://github.com/geni/will_filter.git', :branch => 'rails-3.1.x', :require => false

group :development, :test do
  gem 'fssm', '~> 0.2.10'
  gem 'method_source'
  gem 'mocha', '0.11.4'
  gem 'rake'
  gem 'simplecov',       :require => false
  gem 'sqlite3', '1.6.9'
  gem 'test-unit', '3.6.2' # >3.6.3 have problems with elapsed_time
end

# Disabled vscode group - conflicts with Rails 3.1 dependencies
# group :vscode do
#   gem 'debase',         :require => false
#   gem 'ruby-debug-ide', :require => false
#   gem 'solargraph',     :require => false
# end
