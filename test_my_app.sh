#!/bin/sh
BUNDLE="bundle _1.17.3_"

#bundle config --local build.pg "--with-pg-config=/usr/pgsql-10/bin/pg_config"
bundle config --local build.sqlite3 "--enable-system-libraries"
bundle config --local clean true
bundle config --local path vendor/bundle

# clean and reinstall unless --no-clean is specified
if [[ "$*" != *--no-clean* ]]; then
  rm -rf Gemfile.lock vendor/bundle
  ${BUNDLE} install --without=vscode
fi

rm -f db/test.sqlite3 test/dummy/db/test.sqlite3
${BUNDLE} exec rake db:migrate RAILS_ENV=test
${BUNDLE} exec rake test

