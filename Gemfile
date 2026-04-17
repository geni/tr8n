source 'http://www.rubygems.org'

gemspec

# Use Rails 3.0 compatible branch of will_filter
gem 'will_filter', :git => 'https://github.com/geni/will_filter.git', :ref => '6111ede'

group :development, :test do
  gem 'fssm', '~> 0.2.10'
  gem 'method_source'
  gem 'mocha', '0.11.4'
  gem 'rake'
  gem 'simplecov',       :require => false
  gem 'sqlite3', '1.6.9'
  gem 'test-unit', '3.6.2' # >3.6.3 have problems with elapsed_time
end

group :vscode do
  gem 'debase',         :require => false
  gem 'ruby-debug-ide', :require => false
  gem 'solargraph',     :require => false
end
