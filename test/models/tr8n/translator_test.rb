require 'test_helper'

class  TranslatorTest < Tr8n::TestCase

  test 'cache_key' do
    assert_equal "translator_u#{user.id}", Tr8n::Translator.cache_key(user.id)
  end

  test 'for with non-translator' do
    assert_nil Tr8n::Translator.for(user)
  end

  test 'for with nil user' do
    assert_nil Tr8n::Translator.for(nil)
  end

  test 'for with valid translator' do
    assert_equal translator, Tr8n::Translator.for(user)
  end

  test 'find_or_create with existing translator' do
    assert_equal translator, Tr8n::Translator.find_or_create(user)
  end

  test 'register with nil user' do
    Tr8n::Config.init('en-US', nil)
    assert_nil Tr8n::Translator.register
  end

  test 'register with guest' do
    guest = User.create(:name => 'Guest', :guest => true)
    Tr8n::Config.init('en-US', guest)
    assert_nil Tr8n::Translator.register
  end

  test 'register with valid user' do
    Tr8n::Config.init('en-US', user)
    assert Tr8n::Translator.register.present?
  end

  test 'created translator should have a metric' do
    assert_instance_of Tr8n::TranslatorMetric, translator.total_metric
  end

  test 'created translator should have zero rank' do
    assert_equal 0, translator.rank
  end

  test 'add_translation' do
    Tr8n::Config.init(english.locale, user)
    @tkey = Tr8n::TranslationKey.find_or_create("Hello World")

    assert_instance_of Tr8n::Translation, @tkey.add_translation('Privet Mir')
  end

  test 'block' do
    admin = User.create(:name => 'Admin')
    Tr8n::Translator.register(admin)
    translator.block!(admin)
    lang = Tr8n::Language.create(:locale => 'elbonian', :english_name => 'Elbonian')
    Tr8n::Config.init(lang.locale, user)

    assert translator.blocked?

    assert_raise Tr8n::Exception do
      tkey = Tr8n::TranslationKey.find_or_create("Hello World")
      tkey.add_translation('Privet Mir')
    end
  end

  test 'toggling inline translations' do
    refute translator.inline_mode

    translator.enable_inline_translations!
    assert translator.inline_mode

    translator.disable_inline_translations!
    refute translator.inline_mode
  end

end # class TranslatorTest
