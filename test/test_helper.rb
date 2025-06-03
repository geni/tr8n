require 'mocha/minitest'

require 'pp'

ENV["RAILS_ENV"] = "test"

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

class Tr8n::TestCase < ActiveSupport::TestCase

  def setup
    @current_user = Tr8n::Translator.create!(:id => 1, :user_id => 1, :name => 'Mike', :gender => 'male')
    @english      = Tr8n::Language.for('en-US')
    @russian      = Tr8n::Language.for('ru')
    @spanish      = Tr8n::Language.for('es')

    @default_language = @english
    Tr8n::Config.init(@default_language.locale, @current_user)
  end

end

# create database tables
require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)

require "rails/test_help"

Tr8n::Config.init_language('en-US')
Tr8n::Config.init_language('ru')
Tr8n::Config.init_language('es')
