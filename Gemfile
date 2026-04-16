source 'http://www.rubygems.org'

gemspec

gem 'will_filter', :git => 'https://github.com/geni/will_filter.git', :ref => 'rails-2.3.x'

# Rails LTS sources for free Community plan
git 'https://github.com/makandra/rails.git', :branch => '2-3-lts' do
  gem 'rails', '~>2.3.18'
#  gem 'actionmailer',     :require => false
  gem 'actionpack',       :require => false
  gem 'activerecord',     :require => false
#  gem 'activeresource',   :require => false
  gem 'activesupport',    :require => false
  gem 'railties',         :require => false
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
  gem 'debase',         :require => false
  gem 'ruby-debug-ide', :require => false
  gem 'solargraph',     :require => false
end
