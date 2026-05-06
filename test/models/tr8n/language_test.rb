require 'test_helper'

module Tr8n
  class LanguageTest < TestCase

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
      assert english.default?
    end

    test "default language" do
      assert_equal "en-US", Tr8n::Config.default_locale
      assert_equal "en-US", Tr8n::Config.default_language.locale
    end

    test "translations" do
      assert_equal "Hello World", english.translate("Hello World")
      assert_equal "Hello World", english.translate("Hello {world}", "", :world => "World")
    end

    test 'enable and disable language' do
      english.disable!
      assert english.disabled?
      assert !Tr8n::Language.enabled_languages.include?(english)

      english.enable!
      assert english.enabled?
      assert Tr8n::Language.enabled_languages.include?(english)
    end

    test "prohibited words" do
      default = Tr8n::Config.default_language.reload
      default.update_attributes(:curse_words => "word1, word2, word3")
      assert_equal ["word1", "word2", "word3"], default.bad_words
      assert !default.clean_sentence?("I am using word1 in my sentence")

      spanish.update_attributes(:curse_words => "-word1, word4, word5")
      assert_equal ["word4", "word5", "word2", "word3"], spanish.bad_words
      assert spanish.clean_sentence?("I am using word1 in my sentence")
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
      hello_world.translations.all(:conditions => {:language_id => spanish.id}).map(&:destroy)

      assert_equal "Hello World", spanish.translate("Hello World")
      assert_equal false, spanish.translate("Hello World").tr8n_translation_successful?

      # let's add a translation (automatically upvotes it)
      hello_world.add_translation('Hola Mundo', nil, spanish)
      assert_equal "Hola Mundo", spanish.translate("Hello World")

      # Reload associations to get fresh data
      hello_world.reload
      spanish_translation = hello_world.translations.detect{|t| t.language_id == spanish.id}
      spanish_translator  = spanish_translation.translator

      # let's down vote so that it has 0 votes
      mike = Tr8n::Translator.create!(:id => 2, :user_id => 2, :name => "Mike")
      spanish_translation.vote!(mike, -1)

      # should now be considered not successfully translated
      spanish_translation.reload
      assert_equal 0, spanish_translation.rank

      # Clear cache to ensure we get fresh translation
      Tr8n::Cache.delete("translation_key_#{hello_world.id}_#{spanish.locale}") rescue nil

      assert_equal false, spanish.translate("Hello World").tr8n_translation_successful?
    end

  end # class LanguageTest
end # module Tr8n