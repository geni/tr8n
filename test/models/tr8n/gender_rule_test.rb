require 'test_helper'

class GenderRuleTest < Tr8n::TestCase

  test 'class methods should respect configuration settings' do
    Tr8n::Config.rules_engine[:gender_rule] = {
                                                token_suffixes: ['user', 'actor', 'target'],
                                                object_method:   'gender',
                                                method_values:  {
                                                  female:        'f',
                                                  male:          'm',
                                                  neutral:       'n',
                                                  unknown:       'u'
                                                }
                                              }

    assert_equal 'gender', Tr8n::GenderRule.dependency
    assert_equal ['user', 'actor', 'target'], Tr8n::GenderRule.suffixes

    assert_equal 'f', Tr8n::GenderRule.gender_object_value_for(:female)
    assert_equal 'm', Tr8n::GenderRule.gender_object_value_for(:male)
    assert_equal 'n', Tr8n::GenderRule.gender_object_value_for(:neutral)
    assert_equal 'u', Tr8n::GenderRule.gender_object_value_for(:unknown)

    assert_equal 'male', Tr8n::GenderRule.gender_token_value(mike)
  end

  test 'default_transform' do
    assert_equal 'he',  Tr8n::GenderRule.default_transform('he')
    assert_equal 'he',  Tr8n::GenderRule.default_transform('he', 'she')
    assert_equal 'his', Tr8n::GenderRule.default_transform('his', 'her')
  end

  test 'transform' do
    assert_equal 'registered on', Tr8n::GenderRule.transform(mike, 'registered on')
    assert_equal 'he', Tr8n::GenderRule.transform(mike, 'he', 'she')
    assert_equal 'his', Tr8n::GenderRule.transform(mike, 'his', 'her')
    assert_equal 'he', Tr8n::GenderRule.transform(mike, 'he', 'she', 'he/she')

    assert_equal 'registered on', Tr8n::GenderRule.transform(anna, 'registered on')
    assert_equal 'she', Tr8n::GenderRule.transform(anna, 'he', 'she')
    assert_equal 'her', Tr8n::GenderRule.transform(anna, 'his', 'her')
    assert_equal 'she', Tr8n::GenderRule.transform(anna, 'he', 'she', 'he/she')

    assert_equal 'registered on', Tr8n::GenderRule.transform(alex, 'registered on')
    assert_equal 'he/she', Tr8n::GenderRule.transform(alex, 'he', 'she')
    assert_equal 'his/her', Tr8n::GenderRule.transform(alex, 'his', 'her')
    assert_equal 'he/she', Tr8n::GenderRule.transform(alex, 'he', 'she', 'he/she')
  end

  test 'evaluate' do
    definition = {operator: 'is', value: 'male'}
    rule = Tr8n::GenderRule.create(:language => english, :definition => definition)
    assert rule.evaluate(mike)
    refute rule.evaluate(anna)
    refute rule.evaluate(alex)

    definition = {operator: 'is_not', value: 'male'}
    rule = Tr8n::GenderRule.create(:language => english, :definition => definition)
    refute rule.evaluate(mike)
    assert rule.evaluate(anna)
    assert rule.evaluate(alex)

    definition = {operator: 'is', value: 'female'}
    rule = Tr8n::GenderRule.create(:language => english, :definition => definition)
    refute rule.evaluate(mike)
    assert rule.evaluate(anna)
    refute rule.evaluate(alex)

    definition = {operator: 'is_not', value: 'female'}
    rule = Tr8n::GenderRule.create(:language => english, :definition => definition)
    assert rule.evaluate(mike)
    refute rule.evaluate(anna)
    assert rule.evaluate(alex)
  end

  test 'to_hash' do
    definition = {operator: 'is', value: 'male'}
    rule = Tr8n::GenderRule.create(:language => english, :definition => definition)
    assert_equal({:type => 'gender', :operator => 'is', :value => 'male'}, rule.to_hash)
  end

  test 'description' do
    definition = {operator: 'is', value: 'male'}
    rule = Tr8n::GenderRule.create(:language => english, :definition => definition)
    assert_equal 'is a male', rule.description

    definition = {operator: 'is', value: 'unknown'}
    rule = Tr8n::GenderRule.create(:language => english, :definition => definition)
    assert_equal 'has an unknown gender', rule.description

    definition = {operator: 'is_not', value: 'female'}
    rule = Tr8n::GenderRule.create(:language => english, :definition => definition)
    assert_equal 'is not a female', rule.description

    definition = {operator: 'is_not', value: 'unknown'}
    rule = Tr8n::GenderRule.create(:language => english, :definition => definition)
    assert_equal 'does not have an unknown gender', rule.description
  end

end # class GenderRuleTest
