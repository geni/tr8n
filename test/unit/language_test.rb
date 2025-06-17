require_relative '../test_helper'

class Tr8n::LanguageTest < Tr8n::TestCase

  test "default language" do
    assert_equal "en-US", Tr8n::Config.default_locale
    assert_equal "en-US", Tr8n::Config.default_language.locale
  end

  test "translations" do
    assert_equal "Hello World", english.translate("Hello World")
    assert_equal "Hello World", english.translate("Hello {world}", "", :world => "World")
  end

  test 'enable and disable language' do
    russian.disable!
    assert russian.disabled?
    assert !Tr8n::Language.enabled_languages.include?(russian)

    russian.enable!
    assert russian.enabled?
    assert Tr8n::Language.enabled_languages.include?(russian)
  end

  test "prohibited words" do
    Tr8n::Config.default_language.update(:curse_words => "word1, word2, word3")
    assert_equal ["word1", "word2", "word3"], english.bad_words
    assert !english.clean_sentence?("I am using word1 in my sentence")

    russian.reload
    russian.update(:curse_words => "-word1, word4, word5")
    assert_equal ["word4", "word5", "word2", "word3"], russian.bad_words
    assert russian.clean_sentence?("I am using word1 in my sentence")
  end

  test "translate" do
    assert_equal "Hello World", english.translate("Hello World")
  end

end # class Tr8n::LanguageTest