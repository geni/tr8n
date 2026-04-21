#!/bin/sh
BUNDLE="bundle _1.17.3_"

#bundle config --local build.pg "--with-pg-config=/usr/pgsql-10/bin/pg_config"
bundle config --local build.sqlite3 "--enable-system-libraries"
bundle config --local clean true
bundle config --local path vendor/bundle
bundle config --local without vscode

rm Gemfile.lock
rm -rf vendor/bundle

${BUNDLE} install

rm db/test.sqlite3
${BUNDLE} exec rake test

