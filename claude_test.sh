#!/bin/sh

# Usage: time ./claude_test.sh | tee claude.out

# turn on debugging
#set -x

# stop if any command fails
set -e
set -o pipefail

bundle config --local build.sqlite3 "--enable-system-libraries"
bundle config --local clean true
bundle config --local path vendor/bundle
bundle config --local without vscode


# Show which tests are being run and their results
#export TEST_OPTS="--verbose --no-show-detail-immediately"
export TEST_OPTS="--verbose --no-show-detail-immediately --stop-on-failure"

# In case claude made changes to gems
rm -rf vendor/bundle
bundle install
next bundle install

# Run tests in order: Rails 2.3 first, then Rails 3.0
for bx in 'bundle exec' 'next'
do
  rm -f log/test.log

  # Reinstall gems before each test run to ensure correct versions
  if [ "$bx" = "next" ]; then
    next bundle install
    # Patch Rails 3.0 for Ruby 2.7 compatibility after install
    ./script/patch_rails_3_for_ruby_27.sh
  else
    bundle install
  fi

  # Undike for rails 6.1+
  #$bx rails zeitwerk:check

  rm -f db/test.sqlite3
  $bx rake test
done
