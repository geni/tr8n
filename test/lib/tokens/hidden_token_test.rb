require 'test_helper'

class HiddenTokenTest < Tr8n::TestCase

  test 'registering incorrect tokens' do
    [
      'Hello {user:}',
      'Hello {} and welcome',
      'Hello {user::}',
      'You have {count} messages',
      'You have {count:number}',
      'Hello {user:gender}',
      'Today is {today:date}',
      'Hello {user_list:list}',
      '{long_token_name} like this message',
      'Hello {user1}',
      'Hello {user1:user}',
      'Hello {user1:user::pos} and welcome',
      '{user:gender|his,her}',
      '{count:number|message}',
      '{count:number||message}',
      'Dear {user:gender}, you have {count:number||message}',
      '{count | message}',
      '{count | message, messages}',
      '{count:number | message, messages}',
      '{user:gender | he, she, he/she}',
      '{now:date | did, does, will do}',
      '{users:list | all male, all female, mixed genders}',
      '{count || message, messages}'
    ].each do |label|
      assert_equal 0, Tr8n::Tokens::HiddenToken.parse(label).count
    end
  end

  test 'registering correct tokens' do
    [
      '{_he_she}',
      '{_posted__items}',
      'Hello {user.name} you have {count} {_posted__items}'
    ].each do |label|
      tokens = Tr8n::Tokens::HiddenToken.parse(label)
      assert_equal 1, tokens.count
      assert_equal "Tr8n::Tokens::HiddenToken", tokens.first.class.name
    end
  end

end # class HiddenTokenTest
