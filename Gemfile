source 'http://www.rubygems.org'

gemspec

def next?
  File.basename(__FILE__) == 'Gemfile.next'
end

# Use Rails 3.1 or 3.2 compatible branch of will_filter
if next?
  gem 'will_filter', :git => 'https://github.com/geni/will_filter.git', :branch => 'rails-3.2.x'
else
  gem 'will_filter', :git => 'https://github.com/geni/will_filter.git', :branch => 'rails-3.1.x'
end

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
  # TBD
end
