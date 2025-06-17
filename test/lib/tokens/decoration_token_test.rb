require 'test_helper'

class DecorationTokenTest < Tr8n::TestCase
  test 'identifying incorrect tokens' do
    [
      'Hello {bold}',
      'Hello [bold}',
      'Hello [bold]',
      'Hello [[bold]',
      'Hello [[bold]]',
      'Hello [[bold]]',
      'You have [bold {count}] messages',
    ].each do |label|
      assert_empty Tr8n::Tokens::DecorationToken.parse(label)
    end
  end

  test 'identifying correct tokens' do
    [
      'Hello [bold: Mike]',
      'Hello [link: test]',
      'Hello [a: test]',
      'Hello [1: test]',
      'You have [bold: {count}] messages',
      'You have [bold: {count|| message}]',
      '[link: {count} {_messages}]',
      '[link: {count||message}]',
      '[link: {count||person, people}]',
      '[link: {user.name}]'
    ].each do |label|
      assert_equal 1, Tr8n::Tokens::DecorationToken.parse(label).count
    end

    [
      'You have [link1: {msg_count|| message}] and [link2: {alert_count|| alert}]',
    ].each do |label|
      assert_equal 2, Tr8n::Tokens::DecorationToken.parse(label).count
    end
  end

end # class DecorationTokenTest