require 'test_helper'

class TranslationKeyTest < Tr8n::TestCase

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

    male    = stub('male',    :to_s => 'michael', :gender => 'male')
    female  = stub('female',  :to_s => 'anna',    :gender => 'female')
    unknown = stub('unknown', :to_s => 'alex',    :gender => 'unknown')

    assert_equal 'born on:', key.translate(english, {:user => male})
    assert_equal 'born on:', key.translate(english, {:user => female})

    assert_equal 'rodilsya:',          key.translate(russian, {:user => male})
    assert_equal "rodilas':",          key.translate(russian, {:user => female})
    assert_equal "rodilsya/rodilas':", key.translate(russian, {:user => unknown})

    key = Tr8n::TranslationKey.find_or_create('{user} updated {user|his, her} profile.')
    key.add_translation("{user} obnovil svoi profil'.", [{:token=>'user', :rule_id=>[rule1.id]}], russian, translator)
    key.add_translation("{user} obnovila svoi profil'.", [{:token=>'user', :rule_id=>[rule2.id]}], russian, translator)
    key.add_translation("{user} obnovil/obnovila svoi profil'.", [{:token=>'user', :rule_id=>[rule3.id]}], russian, translator)

    assert_equal 'michael updated his profile.', key.translate(english, {:user => male})
    assert_equal 'anna updated her profile.', key.translate(english, {:user => female})

    assert_equal "michael obnovil svoi profil'.", key.translate(russian, {:user => male})
    assert_equal "anna obnovila svoi profil'.", key.translate(russian, {:user => female})
    assert_equal "alex obnovil/obnovila svoi profil'.", key.translate(russian, {:user => unknown})
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

    male    = stub('male',    :to_s => 'Michael', :gender => 'male')
    female  = stub('female',  :to_s => 'Anna',    :gender => 'female')
    unknown = stub('unknown', :to_s => 'Alex',    :gender => 'unknown')

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

    assert_equal 'Dear Michael, you have <b>1 message</b>.', key.translate(english, {:user => male, :count => 1, :bold => '<b>{$0}</b>'})
    assert_equal 'Dear Anna, you have <b>1 message</b>.', key.translate(english, {:user => female, :count => 1, :bold => '<b>{$0}</b>'})

    assert_equal 'Dear Michael, you have <b>5 messages</b>.', key.translate(english, {:user => male, :count => 5, :bold => '<b>{$0}</b>'})
    assert_equal 'Dear Anna, you have <b>5 messages</b>.', key.translate(english, {:user => female, :count => 5, :bold => '<b>{$0}</b>'})

    assert_equal "Dorogoi Michael, u vas est' <b>1 soobshenie</b>.", key.translate(russian, {:user => male, :count => 1, :bold => '<b>{$0}</b>'})
    assert_equal "Dorogaya Anna, u vas est' <b>1 soobshenie</b>.", key.translate(russian, {:user => female, :count => 1, :bold => '<b>{$0}</b>'})

    assert_equal "Dorogoi Michael, u vas est' <b>2 soobsheniya</b>.", key.translate(russian, {:user => male, :count => 2, :bold => '<b>{$0}</b>'})
    assert_equal "Dorogaya Anna, u vas est' <b>2 soobsheniya</b>.", key.translate(russian, {:user => female, :count => 2, :bold => '<b>{$0}</b>'})

    assert_equal "Dorogoi Michael, u vas est' <b>5 soobshenii</b>.", key.translate(russian, {:user => male, :count => 5, :bold => '<b>{$0}</b>'})
    assert_equal "Dorogaya Anna, u vas est' <b>5 soobshenii</b>.", key.translate(russian, {:user => female, :count => 5, :bold => '<b>{$0}</b>'})
  end

  test 'translation with possessive language cases' do
    michael = stub('male',    :to_s => 'Michael', :gender => 'male')
    anna    = stub('female',  :to_s => 'Anna',    :gender => 'female')

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
    assert_equal "Michael updated Anna's profile.", key.translate(english, {:actor => michael, :target => anna})
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

private

  def mike
    @mike ||= User.create!(:name => 'Mike', :gender => 'male')
  end

  def translator
    @translator ||= Tr8n::Translator.create!(:name => 'Mike', :user => mike, :gender => 'male')
  end

  def anna
    @anna ||= User.create!(:name => 'Anna', :gender => 'female')
  end

end # class TranslationKeyTest
