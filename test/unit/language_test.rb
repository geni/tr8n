require 'test_helper'

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
    assert_equal "Hello World", spanish.translate("Hello World")
  end

  test "translations found" do
    assert_equal "Hello World", english.translate("Hello World")
    assert_equal true, english.translate("Hello World").tr8n_translation_successful?

    # there is no translation for "Hello World" in Spanish
    assert_equal "Hello World", spanish.translate("Hello World")
    assert_equal false, spanish.translate("Hello World").tr8n_translation_successful?
  end

  test "translation with 0 rank not considered translated" do
    hello_world = Tr8n::TranslationKey.find_or_create('Hello World')

    # reset if there is a translation for spanish
    hello_world.translations.where(:language => spanish).destroy_all

    assert_equal "Hello World", spanish.translate("Hello World")
    assert_equal false, spanish.translate("Hello World").tr8n_translation_successful?

    # let's add a translation (automatically upvotes it)
    hello_world.add_translation('Hola Mundo', nil, spanish)
    assert_equal "Hola Mundo", spanish.translate("Hello World")

    spanish_translation = hello_world.translations.filter{|t| t.language_id == spanish.id}.first
    spanish_translator  = spanish_translation.translator

    # let's down vote so that it has 0 votes
    spanish_translation.vote!(translator, -1)

    # should now be considered not successfully translated
    assert_equal 0, spanish_translation.rank
    assert_equal false, spanish.translate("Hello World").tr8n_translation_successful?
  end

end # class Tr8n::LanguageTest
