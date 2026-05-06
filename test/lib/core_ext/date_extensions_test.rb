require 'test_helper'

class DateExtensionsTest < Tr8n::TestCase

  test 'trl' do
    tuesday = Tr8n::TranslationKey.find_or_create('Tuesday', 'Day of a week')
    tuesday.add_translation('Martes', nil, spanish)
    may = Tr8n::TranslationKey.find_or_create('May', 'Month name')
    may.add_translation('Mayo', nil, spanish)

    date = Date.new(1968, 5, 21)
    assert_equal 'Tuesday May', date.trl('%A %B')
    assert_equal 'Martes Mayo', date.trl('%A %B', spanish)
  end

end # class DateExtensionsTest
