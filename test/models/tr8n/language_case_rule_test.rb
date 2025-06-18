require 'test_helper'

class LanguageCaseRuleTest < Tr8n::TestCase

  test 'evaluate simple rules without genders' do
    lcrule = Tr8n::LanguageCaseRule.create(
        :language => english,
        :language_case => lcase_en,
        :definition => {
          part1: 'ends_in',
          value1: 's',
          operation: 'append',
          operation_value: "'"
    })

    assert lcrule.is_a?(Tr8n::LanguageCaseRule)

    assert_equal 'ends_in', lcrule.definition[:part1]
    assert_equal 'ends_in', lcrule.definition['part1']

    refute lcrule.evaluate_part('Michael', 1)
    refute lcrule.evaluate(nil, 'Michael')

    refute lcrule.evaluate_part('Anna', 1)
    refute lcrule.evaluate(nil, 'Anna')

    assert lcrule.evaluate_part('friends', 1)
    assert lcrule.evaluate(nil, 'friends')
    assert_equal "friends'", lcrule.apply('friends')

    lcrule = Tr8n::LanguageCaseRule.create(
        :language => english,
        :language_case => lcase_en,
        :definition => {
          part1: 'does_not_end_in',
          value1: 's', operation: 'append',
          operation_value: "'s"
    })

    assert lcrule.evaluate(nil, 'Michael')
    assert_equal "Michael's", lcrule.apply('Michael')

    assert lcrule.evaluate(nil, 'Anna')
    assert_equal "Anna's", lcrule.apply('Anna')

    refute lcrule.evaluate(nil, 'friends')

    lcrule = Tr8n::LanguageCaseRule.create(
        :language => english,
        :language_case => lcase_en,
        :definition => {
          part1: 'is',
          value1: '1',
          operation: 'replace',
          operation_value: 'first',
    })

    refute lcrule.evaluate(nil, '2')
    assert lcrule.evaluate(nil, '1')
    assert_equal 'first', lcrule.apply('1')

    lcrule = Tr8n::LanguageCaseRule.create(
        :language => english,
        :language_case => lcase_en,
        :definition => {
          part1: 'ends_in',
          value1: '0,4,5,6,7,8,9,11,12,13',
          operation: 'append',
          operation_value: 'th',
    })

    assert lcrule.evaluate(nil, '4')
    assert_equal '4th', lcrule.apply('4')

    assert lcrule.evaluate(nil, '7')
    assert_equal '7th', lcrule.apply('7')
  end

  test 'evaluate simple rules with genders' do
    lcrule1 = Tr8n::LanguageCaseRule.create(
        :language => @russian,
        :language_case => @lcase_ru,
        :definition => {
          gender: 'female',
          part1: 'is',
          value1: '1',
          operation: 'replace',
          operation_value: 'pervaya',
    })

    lcrule2 = Tr8n::LanguageCaseRule.create(
        :language => @russian,
        :language_case => @lcase_ru,
        :definition => {
          gender: 'male',
          part1: 'is',
          value1: '1',
          operation: 'replace',
          operation_value: 'pervii',
    })

    anna    = stub('female', :to_s => 'Anna', :gender => 'female')
    michael = stub('male', :to_s => 'Michael', :gender => 'male')

    refute lcrule1.evaluate(michael, '1')
    assert lcrule1.evaluate(anna, '1')
    assert_equal 'pervaya', lcrule1.apply('1')

    refute lcrule2.evaluate(anna, '1')
    assert lcrule2.evaluate(michael, '1')
    assert_equal 'pervii', lcrule2.apply('1')
  end

  test 'apply should replace values' do
    lcrule = Tr8n::LanguageCaseRule.create(
        :language => english,
        :language_case => @lcase_ru,
        :definition => {
          part1: 'is',
          value1: '1',
          operation: 'replace',
          operation_value: '1st',
    })

    assert lcrule.evaluate(nil, '1')
    assert_equal '1st', lcrule.apply('1')
  end

  test 'apply should append values' do
    lcrule = Tr8n::LanguageCaseRule.create(
        :language => english,
        :language_case => @lcase_ru,
        :definition => {
          part1: 'is',
          value1: '1',
          operation: 'append',
          operation_value: 'st',
    })

    assert lcrule.evaluate(nil, '1')
    assert_equal '1st', lcrule.apply('1')
  end

  test 'apply should prepand values' do
    lcrule = Tr8n::LanguageCaseRule.create(
        :language => english,
        :language_case => @lcase_ru,
        :definition => {
          part1: 'starts_with',
          value1: 'q,w,r,t,p,s,d,f,g,j,k,h,l,z,x,c,v,b,n,m',
          operation: 'prepand',
          operation_value: 'a ',
    })

    assert lcrule.evaluate(nil, 'car')
    assert_equal 'a car', lcrule.apply('car')

    lcrule = Tr8n::LanguageCaseRule.create(
        :language => english,
        :language_case => @lcase_ru,
        :definition => {
          part1: 'starts_with',
          value1: 'e,u,i,o,a',
          operation: 'prepand',
          operation_value: 'an ',
    })

    assert lcrule.evaluate(nil, 'apple')
    assert_equal 'an apple', lcrule.apply('apple')
  end

private

  def lcase_en
    Tr8n::LanguageCase.create!(
      language:     english,
      translator:   translator,
      keyword:      'pos',
      latin_name:   'Possessive',
      native_name:  'Possessive',
      description:  "Used to indicate possession (i.e., ownership). It is usually created by adding 's to the word",
      application:  'phrase'
    )
  end

  def lcase_ru
    Tr8n::LanguageCase.create!(
      language:     russian,
      translator:   translator,
      keyword:      'pos',
      latin_name:   'Possessive',
      native_name:  'Possessive',
      description:  'Used to indicate possession (i.e., ownership).',
      application:  'words'
    )
  end

end # class LanguageCaseRuleTest
