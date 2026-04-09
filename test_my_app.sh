#!/bin/sh

#jbundle config --local build.pg "--with-pg-config=/usr/pgsql-10/bin/pg_config"
bundle config --local build.sqlite3 "--enable-system-libraries"
bundle config --local clean true
bundle config --local path vendor/bundle
bundle config --local without vscode

rm Gemfile.lock
bundle install

rm db/test.sqlite3
bundle exec rake test
