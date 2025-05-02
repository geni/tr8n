# this will need to go away once we make tr8n a gem
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + "/../../will_filter/app/models")

require 'pp'

ENV["RAILS_ENV"] = "test"

module CaptureRubyWarnings
  def warn(message)
    return if message =~ /assigned but unused variable/
    return if caller[0] =~ /vendor/ # Ignore warnings from vendored code
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

require File.expand_path(File.dirname(__FILE__) + '/../config/environment')
require 'test_help'

# create database tables
Dir[File.expand_path(File.dirname(__FILE__) + '/../db/migrate/*.rb')].each do |file|
  require file
end

ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate("db/migrate/")