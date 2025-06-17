require 'test_helper'

class TimeExtensionsTest < Tr8n::TestCase

  test 'trl' do
    tuesday = Tr8n::TranslationKey.find_or_create('Tuesday', 'Day of a week')
    tuesday.add_translation('Martes', nil, spanish)
    may = Tr8n::TranslationKey.find_or_create('May', 'Month name')
    may.add_translation('Mayo', nil, spanish)

    time = Time.new(1968, 5, 21, 12, 59, 0, '-05:00')
    assert_equal 'Tuesday May 12:59', time.trl('%A %B %H:%M')
    assert_equal 'Martes Mayo 12:59',  time.trl('%A %B %H:%M', spanish)
  end

end # class TimeExtensionsTest
