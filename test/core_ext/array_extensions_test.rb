require_relative '../test_helper'

class ArrayExtensionsTest < Tr8n::TestCase

  test 'trl' do
    hello = Tr8n::TranslationKey.find_or_create('Hello')
    hello.add_translation('Hola', nil, @spanish)
    goodbye = Tr8n::TranslationKey.find_or_create('Goodbye')
    goodbye.add_translation('Adios', nil, @spanish)

    array = ['Hello', 'Goodbye']
    assert_equal array, array.trl
    assert_equal ['Hola', 'Adios'], array.trl(nil, {}, @spanish)
  end

end # class ArrayExtensionsTest