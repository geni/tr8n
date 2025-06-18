require 'test_helper'

class LanguageTest < Tr8n::TestCase

  test 'find_or_create' do
    lang = Tr8n::Language.find_or_create('test', 'Test Language')
    assert_equal 'test', lang.locale
    assert_equal 'Test Language', lang.english_name

    assert_equal lang, Tr8n::Language.find_or_create('test', 'Test Language')
  end

  test 'for with absent language' do
    assert_nil Tr8n::Language.for('test')
  end

  test 'for' do
    Tr8n::Language.create!(:locale => 'test123', :english_name => 'Test Language 123')

    lang = Tr8n::Language.for('test123')
    assert_equal 'Test Language 123', lang.english_name
  end

  test 'current?' do
    lang = Tr8n::Language.find_or_create('test', 'Test Language')
    refute lang.current?
    Tr8n::Config.init(lang.locale)
    assert lang.current?
  end

  test 'default?' do
    lang = Tr8n::Language.find_or_create('test', 'Test Language')
    refute lang.default?

    Tr8n::Config.stubs(:default_locale => lang.locale)
    assert lang.default?
  end

end # LanguageTest
