require 'test_helper'

class TokenizedLabelTest < Tr8n::TestCase

  test 'registration' do
    str = 'Dear {user:gender}, you have [bold: {count:number|| new message}] in your mailbox!'

    label = Tr8n::TokenizedLabel.new(str)
    assert_equal str, label.label

    assert label.tokens?
    assert label.data_tokens?
    assert label.decoration_tokens?

    assert_equal 2, label.data_tokens.count
    assert_equal 1, label.decoration_tokens.count

    assert_equal 3, label.tokens.count

    assert_equal ["{user}", "{count}", "[bold: ]"], label.sanitized_tokens_hash.keys

    assert label.translation_tokens?
    assert_equal 3, label.translation_tokens.count

    san_str = "Dear {user}, you have [bold: {count} new messages] in your mailbox!"
    assert_equal san_str, label.sanitized_label

    assert_equal ["{user}", "{count}", "bold"], label.suggestion_tokens

    assert_equal ["Dear", "User", "Have", "Bold", "Count", "Messages", "Your", "Mailbox"], label.words

    label.tokens.each do |token|
      assert label.allowed_token?(token)
    end
  end

end # class TokenizedLabelTest
