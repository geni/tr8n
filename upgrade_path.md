# Versions
- 4.0 - ruby >= 1.9.3, relation lambda syntax,  ActiveSupport::Concern
- 4.1 - ruby >= 2.2.2, before_action
- 4.2 - ruby >= 2.2.2, ActiveJob
- 5.0 - ruby >= 2.2.2, ApplicationRecord, ApplicationMailer
- 5.1 - ruby >= 2.2.2
- 5.2 - ruby >= 2.2.2
- 6.0 - ruby >= 2.5.0, update_attributes deprecated, parallel testing
- 6.1 - ruby >= 2.5.0
- 7.0 - ruby >= 2.7.0
- 7.1 - ruby >= 2.7.0
- 7.2 - ruby >= 3.1.0
- 8.0 - ruby >= 3.2.0
- 8.1 - ruby >= 3.2.0

# Steps

## Create branch
```sh
git co <current version>
git co -b <next version>
```

## Setup for dual boot
```sh
gem install --user-install --no-document next_rails
```

## Invoke claude
```sh
# disable colorized output
export NO_COLOR=1

claude "use next_rails to upgrade this rails plugin/gem to <next version>. make sure claude_test.sh passes"
```
# Commit changes

## Remove old code
Use the following prompt to remove the old code:
``
now remove the old code so its only rails <next version> compatible and make sure test_my_app.sh passes
``

# Notes

- [Rails Compatability Table](https://www.fastruby.io/blog/ruby/rails/versions/compatibility-table.html)

