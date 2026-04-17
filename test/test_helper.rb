# this will need to go away once we make tr8n a gem
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../../will_filter/app/models")

require 'pp'

ENV["RAILS_ENV"] = "test"

module CaptureRubyWarnings
  def warn(message)
    return if message =~ /assigned but unused variable/
    return if caller[0] =~ /vendor/ || message =~ /vendor/ # Ignore warnings from vendored code
    super
  end
end
Warning.extend(CaptureRubyWarnings)

unless defined?($SKIP_COVERAGE)
  require 'simplecov'
  SimpleCov.start do
    add_filter 'config'
    add_filter 'test'
    add_filter 'vendor'
  end
end

class Object
  def tap_pp(*args)
    pp [*args, self]
    self
  end
end

require_relative '../config/environment'

# Set up database connection for Rails 3.1+
if defined?(Rails::VERSION) && Rails::VERSION::MAJOR >= 3
  # Rails 3.1 requires explicit database connection setup
  db_config = YAML.load_file(File.expand_path('../../config/database.yml', __FILE__))
  ActiveRecord::Base.establish_connection(db_config['test'])
end

class Tr8n::TestCase < ActiveRecord::TestCase
  # Enable transactional tests - rollback after each test
  # Rails 3.1 uses use_transactional_fixtures, Rails 2.3 uses use_transactional_tests
  if respond_to?(:use_transactional_fixtures=)
    self.use_transactional_fixtures = true
  elsif respond_to?(:use_transactional_tests=)
    self.use_transactional_tests = true
  end

  def setup(*args)
    @current_user = Tr8n::Translator.create!(:id => 1, :user_id => 1, :name => 'Mike', :gender => 'male')
    @english      = Tr8n::Language.for('en-US')
    @russian      = Tr8n::Language.for('ru')
    @spanish      = Tr8n::Language.for('es')

    @default_language = @english
    Tr8n::Config.init(@default_language.locale, @current_user)
  end

end

# Load mocha for Rails 3.1+ (mocha 1.x requires explicit test framework integration)
if defined?(Rails::VERSION) && Rails::VERSION::MAJOR >= 3
  require 'mocha/test_unit'
end

# create database tables
Dir[File.expand_path(File.dirname(__FILE__) + '/../db/migrate/*.rb')].each do |file|
  require file
end

ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate("db/migrate/")

Tr8n::Config.init_language('en-US')
Tr8n::Config.init_language('ru')
Tr8n::Config.init_language('es')
