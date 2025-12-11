require_relative '../test_helper'

class StringExtensionsTest < Tr8n::TestCase

  test 'translate' do
    key = Tr8n::TranslationKey.find_or_create('Hello')
    key.add_translation('Hola', nil, @spanish)

    assert_equal 'Hello', 'Hello'.translate
    assert_equal 'Hola',  'Hello'.translate(nil, {}, {}, @spanish)
  end

  test 'html_safe' do
    string = '<b>foo</b>'
    assert !string.html_safe?
    assert string.html_safe.html_safe?

    string = '<b>foo</b>'.freeze
    assert !string.html_safe?
    assert string.html_safe.html_safe?
  end

end # class StringExtensionsTest
