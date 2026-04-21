#!/bin/sh

bundle config --local clean true
bundle config --local path vendor/bundle
bundle config --local without vscode

# The bundler version can change between branches

if [[ "${CLEAN-1}" == "1" ]]; then
  rm -rf Gemfile.lock vendor/bundle
fi

bundle install

rm -f db/test.sqlite3 test/dummy/db/test.sqlite3 test/dummy/db/schema.rb

bundle exec rails db:create db:migrate
bundle exec rails test
cd test/dummy && bundle exec rails test

