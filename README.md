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
bundle exec rails app:tr8n:bundle_assets
```
This will bundle the javascript changes you made into files specified
in app/assets/javascripts/tr8n/config.yml. The generated files will be
in app/assets/javascripts/tr8n.

## Annotating models
```sh
bundle exec annotaterb models -p before
``

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
bundle exec rails db:seed

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
