require 'test_helper'

class TranslationKeyTest < Tr8n::TestCase

  def setup
    Tr8n::Config.init(russian.locale, user)
  end

  test 'find_or_create' do
    key = Tr8n::TranslationKey.find_or_create('Hello World', 'We must start with this sentence!')
    assert_equal key, Tr8n::TranslationKey.find_or_create('Hello World', 'We must start with this sentence!')
  end

  test 'token creation' do
    key = Tr8n::TranslationKey.find_or_create('Hello {user}, you have {count} messages in your inbox')

    assert key.key.present?
    refute key.translation_tokens.empty?
    assert key.decoration_tokens.empty?
    assert_equal 2, key.tokens.count
    assert_includes key.tokens.collect{|t| t.sanitized_name}, '{user}', '{count}'
    assert_includes key.translation_tokens.collect{|t| t.sanitized_name}, '{user}', '{count}'
  end

  test 'translate simple strings in default language' do
    key = Tr8n::TranslationKey.find_or_create('Hello World')
    assert_equal 'Hello World', key.translate(english)
    assert key.translate(english).html_safe?, 'Translation should be html_safe'

    key = Tr8n::TranslationKey.find_or_create('Hello {world}')
    assert_equal 'Hello World', key.translate(english, :world => 'World')
    assert key.translate(english, :world => 'World').html_safe?, 'Translation should be html_safe'

    key = Tr8n::TranslationKey.find_or_create('{hello_world}')
    assert_equal 'Hello World', key.translate(english, :hello_world => 'Hello World')
    assert key.translate(english, :hello_world => 'Hello World').html_safe?, 'Translation should be html_safe'

    key = Tr8n::TranslationKey.find_or_create('Dear {user:gender}')
    assert_equal 'Dear Mike', key.translate(english, :user => mike)
    assert_equal 'Dear Mike', key.translate(english, :user => [mike, mike.name])
    assert_equal 'Dear Mike', key.translate(english, :user => [mike, :name])
    assert_equal 'Dear Mike', key.translate(english, :user => [mike, lambda{|user| user.name}])
    assert_equal 'Dear Mike and Tom', key.translate(english, :user => [mike, lambda{|user, tom| "#{user.name} and #{tom}"}, 'Tom'])
    assert key.translate(english, :user => [mike, lambda{|user, tom| "#{user.name} and #{tom}"}, 'Tom']).html_safe?, 'Translation should be html_safe'

    key = Tr8n::TranslationKey.find_or_create('{user:gender} updated {user:gender|his,her} profile')
    assert_equal 'Mike updated his profile', key.translate(english, :user => mike)
    assert_equal 'Anna updated her profile', key.translate(english, :user => anna)
    assert key.translate(english, :user => anna).html_safe?, 'Translation should be html_safe'
  end

  test 'translation with no rules' do
    key = Tr8n::TranslationKey.find_or_create('Hello World')
    key.add_translation('Privet Mir', nil, russian, translator)
    assert_equal 'Privet Mir', key.translate(russian)

    key = Tr8n::TranslationKey.find_or_create('Hello {user}')
    key.add_translation('Privet {user}', nil, russian, translator)
    assert_equal 'Privet Mike', key.translate(russian, {:user => mike})

    key = Tr8n::TranslationKey.find_or_create('You have {count} messages.')
    key.add_translation('U vas est {count} soobshenii.', nil, russian, translator)
    assert_equal 'U vas est 5 soobshenii.', key.translate(russian, {:count => 5})
  end

  test 'translation with numeric rules' do
    init_tr8n(mike, translator)
    definition = {multipart: true, part1: 'ends_in', value1: '1', operator: 'and', part2: 'does_not_end_in', value2: '11'}
    rule1 = Tr8n::NumericRule.create(:language => russian, :definition => definition, :translator => translator)

    definition = {multipart: true, part1: 'ends_in', value1: '2,3,4', operator: 'and', part2: 'does_not_end_in', value2: '12,13,14'}
    rule2 = Tr8n::NumericRule.create(:language => russian, :definition => definition, :translator => translator)

    definition = {multipart: false, part1: 'ends_in', value1: '0,5,6,7,8,9,11,12,13,14'}
    rule3 = Tr8n::NumericRule.create(:language => russian, :definition => definition, :translator => translator)

    key = Tr8n::TranslationKey.find_or_create('You have {count||message}.')
    key.add_translation('U vas est {count} soobshenie.', [{:token=>'count', :rule_id=>[rule1.id]}], russian, translator)
    key.add_translation('U vas est {count} soobsheniya.', [{:token=>'count', :rule_id=>[rule2.id]}], russian, translator)
    key.add_translation('U vas est {count} soobshenii.', [{:token=>'count', :rule_id=>[rule3.id]}], russian, translator)

    assert_equal 'U vas est 1 soobshenie.', key.translate(russian, {:count => 1})
    assert_equal 'U vas est 21 soobshenie.', key.translate(russian, {:count => 21})
    assert_equal 'U vas est 31 soobshenie.', key.translate(russian, {:count => 31})
    assert_equal 'U vas est 101 soobshenie.', key.translate(russian, {:count => 101})
    assert_equal 'U vas est 11 soobshenii.', key.translate(russian, {:count => 11})
    assert_equal 'U vas est 111 soobshenii.', key.translate(russian, {:count => 111})

    assert_equal 'U vas est 5 soobshenii.', key.translate(russian, {:count => 5})
    assert_equal 'U vas est 26 soobshenii.', key.translate(russian, {:count => 26})
    assert_equal 'U vas est 106 soobshenii.', key.translate(russian, {:count => 106})

    assert_equal 'U vas est 3 soobsheniya.', key.translate(russian, {:count => 3})
    assert_equal 'U vas est 13 soobshenii.', key.translate(russian, {:count => 13})
    assert_equal 'U vas est 23 soobsheniya.', key.translate(russian, {:count => 23})
    assert_equal 'U vas est 103 soobsheniya.', key.translate(russian, {:count => 103})
  end

  test 'translation with gender rules' do
    definition = {operator: 'is', value: 'male'}
    rule1 = Tr8n::GenderRule.create!(:language => russian, :definition => definition, :translator => translator)

    definition = {operator: 'is', value: 'female'}
    rule2 = Tr8n::GenderRule.create!(:language => russian, :definition => definition, :translator => translator)

    definition = {operator: 'is', value: 'unknown'}
    rule3 = Tr8n::GenderRule.create!(:language => russian, :definition => definition, :translator => translator)

    key = Tr8n::TranslationKey.find_or_create('{user| born on:}')
    key.add_translation('rodilsya:',          [{:token=>'user', :rule_id=>[rule1.id]}], russian, translator)
    key.add_translation("rodilas':",          [{:token=>'user', :rule_id=>[rule2.id]}], russian, translator)
    key.add_translation("rodilsya/rodilas':", [{:token=>'user', :rule_id=>[rule3.id]}], russian, translator)

    assert_equal 'born on:', key.translate(english, {:user => mike})
    assert_equal 'born on:', key.translate(english, {:user => anna})

    assert_equal 'rodilsya:',          key.translate(russian, {:user => mike})
    assert_equal "rodilas':",          key.translate(russian, {:user => anna})
    assert_equal "rodilsya/rodilas':", key.translate(russian, {:user => alex})

    key = Tr8n::TranslationKey.find_or_create('{user} updated {user|his, her} profile.')
    key.add_translation("{user} obnovil svoi profil'.", [{:token=>'user', :rule_id=>[rule1.id]}], russian, translator)
    key.add_translation("{user} obnovila svoi profil'.", [{:token=>'user', :rule_id=>[rule2.id]}], russian, translator)
    key.add_translation("{user} obnovil/obnovila svoi profil'.", [{:token=>'user', :rule_id=>[rule3.id]}], russian, translator)

    assert_equal 'Mike updated his profile.', key.translate(english, {:user => mike})
    assert_equal 'Anna updated her profile.', key.translate(english, {:user => anna})

    assert_equal "Mike obnovil svoi profil'.", key.translate(russian, {:user => mike})
    assert_equal "Anna obnovila svoi profil'.", key.translate(russian, {:user => anna})
    assert_equal "Alex obnovil/obnovila svoi profil'.", key.translate(russian, {:user => alex})
  end

  test 'translation with mixed rules and tokens' do
    definition = {operator: 'is', value: 'male'}
    grule1 = Tr8n::GenderRule.create(:language => russian, :definition => definition, :translator => translator)
    definition = {operator: 'is', value: 'female'}
    grule2 = Tr8n::GenderRule.create(:language => russian, :definition => definition, :translator => translator)
    definition = {operator: 'is', value: 'unknown'}
    grule3 = Tr8n::GenderRule.create(:language => russian, :definition => definition, :translator => translator)

    definition = {multipart: true, part1: 'ends_in', value1: '1', operator: 'and', part2: 'does_not_end_in', value2: '11'}
    nrule1 = Tr8n::NumericRule.create(:language => russian, :definition => definition, :translator => translator)
    definition = {multipart: true, part1: 'ends_in', value1: '2,3,4', operator: 'and', part2: 'does_not_end_in', value2: '12,13,14'}
    nrule2 = Tr8n::NumericRule.create(:language => russian, :definition => definition, :translator => translator)
    definition = {multipart: false, part1: 'ends_in', value1: '0,5,6,7,8,9,11,12,13,14'}
    nrule3 = Tr8n::NumericRule.create(:language => russian, :definition => definition, :translator => translator)

    key = Tr8n::TranslationKey.find_or_create('Dear {user}, you have [bold: {count||message}].')
    key.add_translation("Dorogoi {user}, u vas est' [bold: {count} soobshenie].", [
          {:token=>'user', :rule_id=>[grule1.id]}, {:token=>'count', :rule_id=>[nrule1.id]}
    ], russian, translator)
    key.add_translation("Dorogoi {user}, u vas est' [bold: {count} soobsheniya].", [
          {:token=>'user', :rule_id=>[grule1.id]}, {:token=>'count', :rule_id=>[nrule2.id]}
    ], russian, translator)
    key.add_translation("Dorogoi {user}, u vas est' [bold: {count} soobshenii].", [
          {:token=>'user', :rule_id=>[grule1.id]}, {:token=>'count', :rule_id=>[nrule3.id]}
    ], russian, translator)
    key.add_translation("Dorogaya {user}, u vas est' [bold: {count} soobshenie].", [
          {:token=>'user', :rule_id=>[grule2.id]}, {:token=>'count', :rule_id=>[nrule1.id]}
    ], russian, translator)
    key.add_translation("Dorogaya {user}, u vas est' [bold: {count} soobsheniya].", [
          {:token=>'user', :rule_id=>[grule2.id]}, {:token=>'count', :rule_id=>[nrule2.id]}
    ], russian, translator)
    key.add_translation("Dorogaya {user}, u vas est' [bold: {count} soobshenii].", [
          {:token=>'user', :rule_id=>[grule2.id]}, {:token=>'count', :rule_id=>[nrule3.id]}
    ], russian, translator)

    assert_equal 'Dear Mike, you have <b>1 message</b>.', key.translate(english, {:user => mike, :count => 1, :bold => '<b>{$0}</b>'})
    assert_equal 'Dear Anna, you have <b>1 message</b>.', key.translate(english, {:user => anna, :count => 1, :bold => '<b>{$0}</b>'})

    assert_equal 'Dear Mike, you have <b>5 messages</b>.', key.translate(english, {:user => mike, :count => 5, :bold => '<b>{$0}</b>'})
    assert_equal 'Dear Anna, you have <b>5 messages</b>.', key.translate(english, {:user => anna, :count => 5, :bold => '<b>{$0}</b>'})

    assert_equal "Dorogoi Mike, u vas est' <b>1 soobshenie</b>.", key.translate(russian, {:user => mike, :count => 1, :bold => '<b>{$0}</b>'})
    assert_equal "Dorogaya Anna, u vas est' <b>1 soobshenie</b>.", key.translate(russian, {:user => anna, :count => 1, :bold => '<b>{$0}</b>'})

    assert_equal "Dorogoi Mike, u vas est' <b>2 soobsheniya</b>.", key.translate(russian, {:user => mike, :count => 2, :bold => '<b>{$0}</b>'})
    assert_equal "Dorogaya Anna, u vas est' <b>2 soobsheniya</b>.", key.translate(russian, {:user => anna, :count => 2, :bold => '<b>{$0}</b>'})

    assert_equal "Dorogoi Mike, u vas est' <b>5 soobshenii</b>.", key.translate(russian, {:user => mike, :count => 5, :bold => '<b>{$0}</b>'})
    assert_equal "Dorogaya Anna, u vas est' <b>5 soobshenii</b>.", key.translate(russian, {:user => anna, :count => 5, :bold => '<b>{$0}</b>'})
  end

  test 'translation with possessive language cases' do
    language_case = Tr8n::LanguageCase.create(:language => english,
                  :translator => translator, :keyword => 'pos',
                  :latin_name => 'Possessive', :application => 'phrase')

    language_case.add_rule({
                            part1: 'ends_in', value1: 's',
                            operation: 'append',
                            operation_value: "'"
                            }, :translator => translator)
    language_case.add_rule({
                            part1: 'does_not_end_in',
                            value1: 's',
                            operation: 'append',
                            operation_value: "'s"
                            }, :translator => translator)

    key = Tr8n::TranslationKey.find_or_create('{actor} updated {target::pos} profile.')
    assert_equal "Mike updated Anna's profile.", key.translate(english, {:actor => mike, :target => anna})
  end

  test 'translation using ordinal case in English' do
    lcase = Tr8n::LanguageCase.create(
        :language => english,
        :translator => translator,
        :keyword => 'ord',
        :description => 'The adjective form of the cardinal numbers',
        :latin_name => 'Ordinal',
        :application => 'phrase'
    )
    lcase.add_rule({
        part1:                'is',
        value1:               '1',
        operation:            'replace',
        operation_value:      'first'
    }, :translator => translator)
    lcase.add_rule({
        part1:                'is',
        value1:               '2',
        operation:            'replace',
        operation_value:      'second'
    }, :translator => translator)
    lcase.add_rule({
        part1:                'is',
        value1:               '3',
        operation:            'replace',
        operation_value:      'third'
    }, :translator => translator)
    lcase.add_rule({
        multipart:            'true',
        part1:                'ends_in',
        value1:               '1',
        operator:             'and',
        part2:                'does_not_end_in',
        value2:               '11',
        operation:            'append',
        operation_value:      'st'
    }, :translator => translator)
    lcase.add_rule({
        multipart:            'true',
        part1:                'ends_in',
        value1:               '2',
        operator:             'and',
        part2:                'does_not_end_in',
        value2:               '12',
        operation:            'append',
        operation_value:      'nd'
    }, :translator => translator)
    lcase.add_rule({
        multipart:            'true',
        part1:                'ends_in',
        value1:               '3',
        operator:             'and',
        part2:                'does_not_end_in',
        value2:               '13',
        operation:            'append',
        operation_value:      'rd'
    }, :translator => translator)
    lcase.add_rule({
        part1:                'ends_in',
        value1:               '0,4,5,6,7,8,9,11,12,13',
        operation:            'append',
        operation_value:      'th'
    }, :translator => translator)

    key = Tr8n::TranslationKey.find_or_create('This is your {count::ord} notice!')

    assert_equal 'This is your first notice!', key.translate(english, {:count => 1})
    assert_equal 'This is your second notice!', key.translate(english, {:count => 2})
    assert_equal 'This is your third notice!', key.translate(english, {:count => 3})
    assert_equal 'This is your 4th notice!', key.translate(english, {:count => 4})
    assert_equal 'This is your 5th notice!', key.translate(english, {:count => 5})
    assert_equal 'This is your 12th notice!', key.translate(english, {:count => 12})
    assert_equal 'This is your 42nd notice!', key.translate(english, {:count => 42})
    assert_equal 'This is your 13th notice!', key.translate(english, {:count => 13})
    assert_equal 'This is your 23rd notice!', key.translate(english, {:count => 23})
  end

  test "find or create a translation key" do
    key = Tr8n::TranslationKey.find_or_create("Hello World", "We must start with this sentence!")
    assert key.key
    the_key = Tr8n::TranslationKey.find_or_create("Hello World", "We must start with this sentence!")
    assert key.key, the_key.key
  end

  test "tokens" do
    key = Tr8n::TranslationKey.find_or_create("Hello {user}, you have {count} messages in your inbox")

    assert key.key
    assert key.translation_tokens?
    assert (not key.decoration_tokens?)

    assert_equal ["{user}", "{count}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["{user}", "{count}"], key.translation_tokens.collect{|t| t.sanitized_name}
  end

  test "basic translations" do
    key = Tr8n::TranslationKey.find_or_create("Hello World")
    t = key.translate(default_language)
    assert_equal "Hello World", t

    key = Tr8n::TranslationKey.find_or_create("Hello {world}")
    assert_equal ["{world}"], key.tokens.collect{|t| t.sanitized_name}
    t = key.translate(default_language, :world => "World")
    assert_equal "Hello World", t

    key = Tr8n::TranslationKey.find_or_create("{hello_world}")
    assert_equal ["{hello_world}"], key.tokens.collect{|t| t.sanitized_name}
    t = key.translate(default_language, :hello_world => "Hello World")
    assert_equal "Hello World", t
  end

  test "gender based translations in English" do
    # translator already has name set to "Mike" in setup, just need to set gender
    translator.update_attributes(:gender => "male")

    key = Tr8n::TranslationKey.find_or_create("Dear {user}")
    assert_equal ["{user}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal "Dear Mike", key.translate(default_language, :user => translator)

    key = Tr8n::TranslationKey.find_or_create("Dear {user:gender}")
    assert_equal ["{user}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal "Dear Mike", key.translate(default_language, :user => translator)
    assert_equal "Dear Mike", key.translate(default_language, :user => [translator, translator.name])
    assert_equal "Dear Mike", key.translate(default_language, :user => [translator, :name])
    assert_equal "Dear Mike", key.translate(default_language, :user => [translator, lambda{|user| user.name}])
    assert_equal "Dear Mike and Tom", key.translate(default_language, :user => [translator, lambda{|user, tom| "#{user.name} and #{tom}"}, "Tom"])

    key = Tr8n::TranslationKey.find_or_create("{custom:gender} updated {custom:gender|his,her} profile")
    assert_equal ["{custom:gender}", "{custom:gender|his,her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Mike updated his profile", key.translate(default_language, {:custom => translator})

    key = Tr8n::TranslationKey.find_or_create("{user} updated {user|his,her} profile")
    assert_equal ["{user}", "{user|his,her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Mike updated his profile", key.translate(default_language, :user => translator)

    assert_equal "Anna updated her profile", key.translate(default_language, :user => anna)

    assert_equal "Alex updated his/her profile", key.translate(default_language, :user => alex)

    key = Tr8n::TranslationKey.find_or_create("{user} updated {user | his, her, his-her} profile")
    assert_equal ["{user}", "{user | his, her, his-her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex updated his-her profile", key.translate(default_language, :user => alex)

    # double pipe approach - will include the name
    key = Tr8n::TranslationKey.find_or_create("{user || updated his, updated her, updated his/her} profile")
    assert_equal ["{user || updated his, updated her, updated his/her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex updated his/her profile", key.translate(default_language, :user => [alex, :name])
  end

  test "number based translations in English" do
    # old way of doing things
    key = Tr8n::TranslationKey.find_or_create("{val:number} {_messages}")
    assert_equal ["{val}", "{_messages}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::HiddenToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "5 messages", key.translate(default_language, :val => 5, :_messages => "message".pluralize_for(5))

    key = Tr8n::TranslationKey.find_or_create("{count} {_messages}")
    assert_equal ["{count}", "{_messages}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::HiddenToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "5 messages", key.translate(default_language, :count => 5, :_messages => "message".pluralize_for(5))

    translator.update_attributes(:name => "Alex")
    # Define age method on this instance (since Translator doesn't have age attribute)
    def translator.age; 5; end
    key = Tr8n::TranslationKey.find_or_create("{user} is now {years} {_years} old")
    assert_equal ["{user}", "{years}", "{_years}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::DataToken", "Tr8n::Tokens::HiddenToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Mike is now 5 years old", key.translate(default_language, :user => [translator, :name], :years => translator.age, :_years => "year".pluralize_for(translator.age))

    # new way
    key = Tr8n::TranslationKey.find_or_create("{user} is now {age} {age|year} old")
    assert_equal ["{user}", "{age}", "{age|year}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{age}", "{age}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Mike is now 5 years old", key.translate(default_language, :user => [translator, :name], :age => translator.age)

    key = Tr8n::TranslationKey.find_or_create("{user} is now {age || year} old")
    assert_equal ["{user}", "{age}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Mike is now 5 years old", key.translate(default_language, :user => [translator, :name], :age => translator.age)

    key = Tr8n::TranslationKey.find_or_create("{user} is now {age || year, years} old")
    assert_equal ["{user}", "{age || year, years}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{age}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Mike is now 5 years old", key.translate(default_language, :user => [translator, :name], :age => translator.age)

    key = Tr8n::TranslationKey.find_or_create("{count||person,people}")
    assert_equal ["{count||person,people}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{count}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "1 person", key.translate(default_language, :count => 1)
    assert_equal "2 people", key.translate(default_language, :count => 2)
    assert_equal "0 people", key.translate(default_language, :count => 0)
  end

  test "decoration tokens" do
    # see config/tr8n/tokens/decorations.yml

    key = Tr8n::TranslationKey.find_or_create("[b: hello world]")
    assert_equal ["[b: hello world]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["[b: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "<b>hello world</b>", key.translate(default_language, :b => lambda{|str| "<b>#{str}</b>"})
    assert_equal "<b>hello world</b>", key.translate(default_language, :b => "<b>{$0}</b>")
    assert_equal "<strong>hello world</strong>", key.translate(default_language)

    key = Tr8n::TranslationKey.find_or_create("[link: click here]")
    assert_equal ["[link: click here]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["[link: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "<a href='www.google.com' style=''>click here</a>", key.translate(default_language, :link => ["www.google.com"])

    assert_equal "<a href='www.google.com' style=''>click here</a>", key.translate(default_language, :link => ["www.google.com"])
  end

  test "nested tokens" do
    # see config/tr8n/tokens/decorations.yml
    translator.update_attributes(:name => "Michael")

    key = Tr8n::TranslationKey.find_or_create("Hello [b: {user.name}]")
    assert_equal ["{user.name}", "[b: {user.name}]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user.name}", "[b: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::MethodToken", "Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Hello <strong>Mike</strong>", key.translate(default_language, :user => translator)

    key = Tr8n::TranslationKey.find_or_create("Dear {user}, you have [b: {count||message}] in your inbox")
    assert_equal ["{user}", "{count||message}", "[b: {count||message}]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{count}", "[b: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken", "Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Dear Mike, you have <strong>5 messages</strong> in your inbox", key.translate(default_language, :user => translator, :count => 5)
  end

  test "words" do
    key = Tr8n::TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
    assert_equal ["Hello", "Link1", "User", "Have", "Link2", "Count", "Posted", "Items"], key.words
  end

  test "locking translation key" do
    key = Tr8n::TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
    assert key.unlocked?
    key.lock!
    assert key.locked?
    key.unlock!
    assert key.unlocked?
  end

  test "simple translations" do
    key = Tr8n::TranslationKey.find_or_create("Hello World")

    assert key.add_translation("Привет Мир")

    # for Russian
    assert_equal "Привет Мир", key.translate(russian)

    # for Spanish
    assert_equal "Hello World", key.translate(spanish)
  end

  test "simple token translations" do
    key = Tr8n::TranslationKey.find_or_create("Hello {name}")

    assert key.add_translation("Привет {name}")

    # for Russian
    assert_equal "Привет Mike", key.translate(russian, :name => "Mike")

    # for Spanish
    assert_equal "Hello Mike", key.translate(spanish, :name => "Mike")
  end

  test "object translations" do
    # Define first_name method on this instance (since Translator doesn't have first_name attribute)
    def translator.first_name; 'Mike'; end
    key = Tr8n::TranslationKey.find_or_create("Hello {user.first_name}")
    assert key.add_translation("Привет {user.first_name}")

    # for Russian
    assert_equal "Привет Mike", key.translate(russian, :user => translator)

    # for Spanish
    assert_equal "Hello Mike", key.translate(spanish, :user => translator)
  end

  test "more object translations" do
    key = Tr8n::TranslationKey.find_or_create("Hello {user}")
    assert key.add_translation("Привет {user}")

    assert_equal "Привет Mike", key.translate(russian, :user => [translator, translator.name])
    assert_equal "Привет Mike", key.translate(russian, :user => [translator, :name])
  end

  test "number based translations" do
    key    = Tr8n::TranslationKey.find_or_create("{count} {_messages}")
    lrule1 = Tr8n::NumericRule.create(:language => russian, :definition => {:multipart => false, :part1 => 'is', :value1 => '1'})
    lrule2 = Tr8n::NumericRule.create(:language => russian, :definition => {:multipart => false, :part1 => 'is_not', :value1 => '1'})

    assert key.add_translation("{count} сообщение", [{:token => 'count', :rule_id => [lrule1.id]}])
    assert key.add_translation("{count} сообщений", [{:token => 'count', :rule_id => [lrule2.id]}])

    assert_equal "1 сообщение", key.translate(russian, :count => 1, :_messages => "message")
    assert_equal "10 сообщений", key.translate(russian, :count => 10, :_messages => "messages")
  end

  test "verified_at gets updated when key is accessed with verification enabled" do
    # Save original config value
    original_config = Tr8n::Config.config[:enable_key_verification]

    begin
      # Enable key verification
      Tr8n::Config.config[:enable_key_verification] = true

      # Create a key with verified_at in the past
      past_time = 3.days.ago
      unique_label = "Test verification #{Time.now.to_f}"
      key = Tr8n::TranslationKey.create!(
        :key => Tr8n::TranslationKey.generate_key(unique_label, ""),
        :label => unique_label,
        :description => "",
        :locale => default_language.locale,
        :verified_at => past_time
      )

      # Access the key through find_or_create (which calls verify_key)
      current_time = Time.now
      Tr8n::TranslationKey.find_or_create(unique_label, "")

      # Reload to get fresh data from database
      key.reload

      # verified_at should be updated to approximately now
      assert_not_nil key.verified_at
      assert key.verified_at > past_time, "verified_at should be updated from past time"
      assert (key.verified_at - current_time).abs < 5, "verified_at should be close to current time"
    ensure
      # Restore original config
      Tr8n::Config.config[:enable_key_verification] = original_config
    end
  end

  test "verified_at respects 24-hour throttle" do
    # Save original config value
    original_config = Tr8n::Config.config[:enable_key_verification]

    begin
      # Enable key verification
      Tr8n::Config.config[:enable_key_verification] = true

      # Create a key with verified_at 12 hours ago (within throttle window)
      recent_time = 12.hours.ago
      unique_label = "Test throttle #{Time.now.to_f}"
      key = Tr8n::TranslationKey.create!(
        :key => Tr8n::TranslationKey.generate_key(unique_label, ""),
        :label => unique_label,
        :description => "",
        :locale => default_language.locale,
        :verified_at => recent_time
      )

      original_verified_at = key.verified_at

      # Access the key through find_or_create
      Tr8n::TranslationKey.find_or_create(unique_label, "")

      # Reload to get fresh data from database
      key.reload

      # verified_at should NOT be updated due to 24-hour throttle
      assert_equal original_verified_at.to_i, key.verified_at.to_i,
                   "verified_at should not be updated within 24-hour throttle window"
    ensure
      # Restore original config
      Tr8n::Config.config[:enable_key_verification] = original_config
    end
  end

  test "verified_at not updated when verification disabled" do
    # Save original config value
    original_config = Tr8n::Config.config[:enable_key_verification]

    begin
      # Disable key verification
      Tr8n::Config.config[:enable_key_verification] = false

      # Create a key with verified_at in the past
      past_time = 3.days.ago
      unique_label = "Test disabled #{Time.now.to_f}"
      key = Tr8n::TranslationKey.create!(
        :key => Tr8n::TranslationKey.generate_key(unique_label, ""),
        :label => unique_label,
        :description => "",
        :locale => default_language.locale,
        :verified_at => past_time
      )

      # Access the key through find_or_create
      Tr8n::TranslationKey.find_or_create(unique_label, "")

      # Reload to get fresh data from database
      key.reload

      # verified_at should NOT be updated when verification is disabled
      assert_equal past_time.to_i, key.verified_at.to_i,
                   "verified_at should not be updated when verification is disabled"
    ensure
      # Restore original config
      Tr8n::Config.config[:enable_key_verification] = original_config
    end
  end

  test "touch_sources not called when only verified_at changes" do
    # Create a translation source
    source = Tr8n::TranslationSource.create!(
      :source => "test_controller#test_action_#{Time.now.to_f}"
    )

    # Create a translation key associated with this source
    key = Tr8n::TranslationKey.find_or_create("Test no touch on verify #{Time.now.to_f}")
    Tr8n::TranslationKeySource.create!(
      :translation_key => key,
      :translation_source => source
    )

    # Record source's current updated_at
    source.reload
    original_updated_at = source.updated_at

    # Update only verified_at (simulating usage tracking)
    sleep 0.1 # Small delay to ensure timestamp would change if touched
    key.update_attributes(:verified_at => Time.now)

    # Reload source
    source.reload

    # updated_at should NOT have changed when only verified_at was updated
    assert_equal original_updated_at.to_i, source.updated_at.to_i,
                 "source.updated_at should not be touched when only verified_at changes"
  end

  test "touch_sources respects 24-hour throttle" do
    # Create a translation source
    source = Tr8n::TranslationSource.create!(
      :source => "test_controller#test_action_#{Time.now.to_f}"
    )

    # Create a translation key associated with this source
    key = Tr8n::TranslationKey.find_or_create("Test touch throttle #{Time.now.to_f}")
    Tr8n::TranslationKeySource.create!(
      :translation_key => key,
      :translation_source => source
    )

    # Update source's updated_at to 12 hours ago (within throttle window)
    recent_time = 12.hours.ago
    source.update_attributes(:updated_at => recent_time)
    original_updated_at = source.updated_at

    # Trigger after_save which calls touch_sources (change something other than verified_at)
    key.update_attributes(:description => "Modified")

    # Reload source
    source.reload

    # updated_at should NOT have changed due to 24-hour throttle
    assert_equal original_updated_at.to_i, source.updated_at.to_i,
                 "source.updated_at should not be touched within 24-hour throttle window"
  end

  test "touch_sources updates old sources" do
    # Create a translation source with old updated_at
    source = Tr8n::TranslationSource.create!(
      :source => "test_controller#test_action_old_#{Time.now.to_f}"
    )

    # Create a translation key associated with this source
    key = Tr8n::TranslationKey.find_or_create("Test touch old #{Time.now.to_f}")
    Tr8n::TranslationKeySource.create!(
      :translation_key => key,
      :translation_source => source
    )

    # Update source's updated_at to 3 days ago (outside throttle window)
    old_time = 3.days.ago
    source.update_attributes(:updated_at => old_time)

    # Trigger after_save which calls touch_sources
    current_time = Time.now
    key.update_attributes(:description => "Modified again")

    # Reload source
    source.reload

    # updated_at should have been updated
    assert source.updated_at > old_time,
           "source.updated_at should be touched when older than 24 hours"
    assert (source.updated_at - current_time).abs < 5,
           "source.updated_at should be close to current time"
  end
private

  def default_language
    @default_language ||= Tr8n::Config.default_language
  end

  def translator
    @translator ||= Tr8n::Translator.create!(:name => 'Mike', :user => mike, :gender => 'male')
  end

end # class TranslationKeyTest
