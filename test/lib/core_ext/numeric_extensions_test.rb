require 'test_helper'

class NumericExtensionsTest < Tr8n::TestCase

  test 'translate' do
    assert_equal '42', 42.translate
  end

end # class NumericExtensionsTest