# frozen_string_literal: false

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

class Object
  def tap_pp(*args)
    pp [*args, self]
    self
  end
end

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

module Tr8n
  class TestCase < ActiveSupport::TestCase
    self.use_transactional_fixtures = true

    SETUP = begin
      # run once before all tests are executed and
      # before any other SETUP= blocks in subclasses
    end

    def setup
      Tr8n::Config.reload_config!
      init_tr8n
    end

  private

    def init_tr8n(locale=english.locale, user=self.user)
      Tr8n::Config.init(locale, user)
    end

    def translator
      @translator ||= Tr8n::Translator.create!(:user => user)
    end

    def user
      @user ||= User.create!(:name => 'Mike', :gender => 'male')
    end

    def mike
      @mike ||= User.create!(:name => 'Mike', :gender => 'male')
    end

    def anna
      @anna ||= User.create!(:name => 'Anna', :gender => 'female')
    end

    def alex
      @alex ||= User.create!(:name => 'Alex', :gender => 'unknown')
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

Tr8n::Config.init_language('en-US')
Tr8n::Config.init_language('ru')
Tr8n::Config.init_language('es')
