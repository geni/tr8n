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
    Tr8n::Config.default_language.update(:curse_words => "word1, word2, word3")
    assert_equal ["word1", "word2", "word3"], @default_language.bad_words
    assert !@default_language.clean_sentence?("I am using word1 in my sentence")

    @current_language.reload
    @current_language.update(:curse_words => "-word1, word4, word5")
    assert_equal ["word4", "word5", "word2", "word3"], @current_language.bad_words
    assert @current_language.clean_sentence?("I am using word1 in my sentence")
  end

  test "translate" do
    assert_equal "Hello World", @default_language.translate("Hello World")
  end

end # class Tr8n::LanguageTest