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

require_relative "../test/dummy/config/environment"

module Tr8n

  # TODO: Rename to ModelTestCase?
  class TestCase < ActiveSupport::TestCase

  SETUP = begin
    # run once before all tests are executed and
    # before any other SETUP= blocks in subclasses
    Tr8n::Config.init(Tr8n::Language.for('en-US').locale, User.create!(:name => 'Mike'))
  end

  private

    def init_tr8n(locale=english.locale, user=self.user)
      Tr8n::Config.init(locale, user)
    end

    def user
      @user ||= User.create!(:name => 'Mike', :gender => 'male')
    end

    def translator
      @translator ||= Tr8n::Translator.create!(:id => 1, :user => user)
    end

    def english
      @english ||= Tr8n::Language.for('en-US')
    end

    def russian
      @russian ||= Tr8n::Language.for('ru')
    end

    def spanish
      @spanish ||= Tr8n::Language.for('es')
    end

  end # class TestCase

  class ControllerTest < ActionController::TestCase
    include Engine.routes.url_helpers

    def setup
      @routes = Tr8n::Engine.routes
    end

  private

    def user
      @user ||= User.create!(:name => 'Mike', :gender => 'male', :admin => true)
    end

    def login!(user: self.user, translator: true)
      Tr8n::Translator.register(user) if translator
      request.session[:user_id] = user.id
    end

    def logout
      request.session[:user_id] = nil
    end

    def dump_routes
      require 'rails/commands/routes/routes_command'
      Rails::Command::RoutesCommand.new.perform
    end

  end # ControllerTest

end # module Tr8n

# create database tables
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)

require "rails/test_help"

Tr8n::Config.init_language('en-US')
Tr8n::Config.init_language('ru')
Tr8n::Config.init_language('es')
