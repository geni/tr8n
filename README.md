## Installation

Add the following line to Gemfile:

```ruby
# Gemfile
gem 'tr8n', :git => 'https://github.com/geni/tr8n.git', :branch => 'rails-8.0.x'
```

## Development

## Changing javascript files

If you change javascript files, run the following commands:
```sh
cd app/javascripts
bundle exec bin/compile
```

This will auto-compile the javascript changes you make
into public/javascripts/tr8n.js and public/javascripts/tr8n-compiled.js.

Make sure you bump the version number in the VERSION file before you commit
the updated tr8n-compiled.js.

## Testing

### Running Automated Tests

```sh
# run all tests and generate coverage report in coverage subdir
bundle exec rails db:create db:migrate
bundle exec rails test
```

### Manual Integration Testing

```sh
# populate dummy app database
bundle exec rails db:create
bundle exec rails app:db:seed

# Spin up the server
bundle exec rails server -b 0.0.0.0
```

# Upgrading

```sh
git checkout -b rails-x.y.z
gem install rails-x.y.z

# generate new engine subdir.
rails plugin new tr8n --rc=.railsrc

# copy files over and test.
```

This will create a new engine in the tr8n subdirectory.
You should copy the files over, then make sure the tests pass.

# References

[Rails Engines](https://guides.rubyonrails.org/engines.html)
