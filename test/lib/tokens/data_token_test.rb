require 'test_helper'

class DataTokenTest < Tr8n::TestCase
  test 'registering incorrect tokens' do
    [
      'Hello {user:}',
      'Hello {} and welcome',
      'Hello {user::}'
    ].each do |label|
      assert_equal 0, Tr8n::Tokens::DataToken.parse(label).count
    end
  end

  test 'registering correct tokens' do
    [
      'Hello {user}',
      'You have {count} messages',
      'You have {count:number}',
      'Hello {user:gender}',
      'Today is {today:date}',
      'Hello {user_list:list}',
      '{long_token_name} like this message',
      'Hello {user1}',
      'Hello {user1:user}',
      'Hello {user1:user::pos} and welcome',
    ].each do |label|
      tokens = Tr8n::Tokens::DataToken.parse(label)
      assert_equal 1, tokens.count
      assert_equal 'Tr8n::Tokens::DataToken', tokens.first.class.name
    end

    [
      '{user} has {count} messages',
      '{user1:user} has {count:number} messages'
    ].each do |label|
      tokens = Tr8n::Tokens::DataToken.parse(label)
      assert_equal 2, tokens.count
      assert_equal 'Tr8n::Tokens::DataToken', tokens.first.class.name
    end
  end

end # class DataTokenTest
