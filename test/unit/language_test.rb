require_relative '../test_helper'

class Tr8n::LanguageTest < Tr8n::TestCase

  def setup
    super
    @user = Tr8n::Translator.create!(:id => 2, :user_id => 2, :name => "Mike")
    @current_language = @russian
  end

  test "default language" do
    assert_equal "en-US", Tr8n::Config.default_locale
    assert_equal "en-US", Tr8n::Config.default_language.locale
  end

  test "translations" do
    assert_equal "Hello World", @default_language.translate("Hello World")
    assert_equal "Hello World", @default_language.translate("Hello {world}", "", :world => "World")
  end

  test 'enable and disable language' do
    @current_language.disable!
    assert @current_language.disabled?
    assert !Tr8n::Language.enabled_languages.include?(@current_language)

    @current_language.enable!
    assert @current_language.enabled?
    assert Tr8n::Language.enabled_languages.include?(@current_language)
  end

  test "prohibited words" do
    Tr8n::Config.default_language.update_attributes(:curse_words => "word1, word2, word3")
    assert_equal ["word1", "word2", "word3"], @default_language.bad_words
    assert !@default_language.clean_sentence?("I am using word1 in my sentence")

    @current_language.reload
    @current_language.update_attributes(:curse_words => "-word1, word4, word5")
    assert_equal ["word4", "word5", "word2", "word3"], @current_language.bad_words
    assert @current_language.clean_sentence?("I am using word1 in my sentence")
  end

  test "translate" do
    assert_equal "Hello World", @default_language.translate("Hello World")
    assert_equal "Hello World", @spanish.translate("Hello World")
  end

  test "translations found" do
    assert_equal "Hello World", @default_language.translate("Hello World")
    assert_equal true, @default_language.translate("Hello World").tr8n_translation_successful?

    # there is no translation for "Hello World" in Spanish
    assert_equal "Hello World", @spanish.translate("Hello World")
    assert_equal false, @spanish.translate("Hello World").tr8n_translation_successful?
  end

  test "translation with 0 rank not considered translated" do
    hello_world = Tr8n::TranslationKey.find_or_create('Hello World')

    # reset if there is a translation for spanish
    hello_world.translations.all(:conditions => {:language_id => @spanish.id}).map(&:destroy)

    assert_equal "Hello World", @spanish.translate("Hello World")
    assert_equal false, @spanish.translate("Hello World").tr8n_translation_successful?

    # let's add a translation (automatically upvotes it)
    hello_world.add_translation('Hola Mundo', nil, @spanish)
    assert_equal "Hola Mundo", @spanish.translate("Hello World")

    spanish_translation = hello_world.translations.filter{|t| t.language_id == @spanish.id}.first
    spanish_translator  = spanish_translation.translator

    # let's down vote so that it has 0 votes
    spanish_translation.vote!(@user, -1)

    # should now be considered not successfully translated
    assert_equal 0, spanish_translation.rank
    assert_equal false, @spanish.translate("Hello World").tr8n_translation_successful?


  end

end # class Tr8n::LanguageTest