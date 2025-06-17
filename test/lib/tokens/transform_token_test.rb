require 'test_helper'

 class TransformTokenTest < Tr8n::TestCase

  test 'registering incorrect tokens' do
    [
      'Hello {user}',
      'Hello {user:}',
      'Hello {user::}'
    ].each do |label|
      assert_empty Tr8n::Tokens::TransformToken.parse(label)
    end
  end

  test 'registering correct tokens' do
    [
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
      tokens = Tr8n::Tokens::TransformToken.parse(label)
      assert_equal 1, tokens.count
      assert_equal Tr8n::Tokens::TransformToken.name, tokens.first.class.name
    end

    [
      '{user:gender|He, She} received {count:number||message}',
      '{user:gender | He, She } received {count:number || message, messages }'
    ].each do |label|
      tokens = Tr8n::Tokens::TransformToken.parse(label)
      assert_equal 2, tokens.count
      assert_equal Tr8n::Tokens::TransformToken.name, tokens.first.class.name
    end
  end

end # class TransformTokenTest
