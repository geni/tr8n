require 'test_helper'

class NumericRuleTest < Tr8n::TestCase

  test 'class methods should respect configuration settings' do
    Tr8n::Config.stubs(:rules_engine => {
      :numeric_rule => {
                        token_suffixes: ['count', 'num'],
                        object_method:   'to_i'
                        }
    })

    assert_equal 'number', Tr8n::NumericRule.dependency
    assert_equal ['count', 'num'], Tr8n::NumericRule.suffixes
    assert_equal 5, Tr8n::NumericRule.number_token_value(5)

    obj = stub('numeric_object', :to_i => 42)
    assert_equal 42, Tr8n::NumericRule.number_token_value(obj)
  end

  test 'default_transform without token value' do
    assert_equal 'cars', Tr8n::NumericRule.default_transform('car', 'cars')
    assert_equal 'cars', Tr8n::NumericRule.default_transform('car')
  end

  test 'transform with a token value' do
    assert_equal 'person', Tr8n::NumericRule.transform(1, 'person', 'people')
    assert_equal 'people', Tr8n::NumericRule.transform(2, 'person', 'people')
    assert_equal 'cars', Tr8n::NumericRule.transform(2, 'car')
  end

  test 'sanitize values' do
    assert_equal ['1','2','3','4'], Tr8n::NumericRule.sanitize_values('1,  2, 3 ,  4 ')
    assert_equal ['1','2','3','4'], Tr8n::NumericRule.sanitize_values('1,2,3,4')
  end

  test 'humanize values' do
    assert_equal '1, 2, 3, 4', Tr8n::NumericRule.humanize_values('1,  2, 3 ,  4 ')
    assert_equal '1, 2, 3, 4', Tr8n::NumericRule.humanize_values('1,2,3,4')
  end

  test 'evaluate_partial_rule' do
    rule = Tr8n::NumericRule.new
    assert rule.evaluate_partial_rule(5, 	:is, [5])
    assert rule.evaluate_partial_rule(5, 	:is, [2,3,5])
    refute rule.evaluate_partial_rule(5, 	:is, [4])

    assert rule.evaluate_partial_rule(5, 	:is_not, [4])
    assert rule.evaluate_partial_rule(5, 	:is_not, [4,2,3])
    refute rule.evaluate_partial_rule(5, 	:is_not, [5])

    assert rule.evaluate_partial_rule(5,  	:ends_in, [5])
    assert rule.evaluate_partial_rule(25, 	:ends_in, [5])
    assert rule.evaluate_partial_rule(25, 	:ends_in, [2,3,4,5])
    refute rule.evaluate_partial_rule(5, 	:ends_in, [2])
    refute rule.evaluate_partial_rule(5, 	:ends_in, [2,3,4])

    assert rule.evaluate_partial_rule(5, 	:does_not_end_in, [2,3,4])
    assert rule.evaluate_partial_rule(25, 	:does_not_end_in, [2,4])
    refute rule.evaluate_partial_rule(25, 	:does_not_end_in, [2,5])
    refute rule.evaluate_partial_rule(25, 	:does_not_end_in, [5])
  end

  test 'create' do
    definition = {multipart: false, part1: 'is', value1: '1'}
    rule = Tr8n::NumericRule.create(:language => lang, :definition => definition)
    assert rule.is_a?(Tr8n::NumericRule)
  end

  test 'evaluate simple rule' do
    definition = {multipart: false, part1: 'is', value1: '1,2,3,4'}
    rule = Tr8n::NumericRule.create(:language => lang, :definition => definition)
    refute rule.evaluate(5)
    assert rule.evaluate(1)

    definition = {multipart: false, part1: 'is_not', value1: '2,3,4,5'}
    rule = Tr8n::NumericRule.create(:language => lang, :definition => definition)
    refute rule.evaluate(5)
    assert rule.evaluate(1)

    definition = {multipart: false, part1: 'ends_in', value1: '2,3,4,5'}
    rule = Tr8n::NumericRule.create(:language => lang, :definition => definition)
    assert rule.evaluate(25)
    refute rule.evaluate(1)

    definition = {multipart: false, part1: 'does_not_end_in', value1: '2,3,4,5'}
    rule = Tr8n::NumericRule.create(:language => lang, :definition => definition)
    refute rule.evaluate(25)
    assert rule.evaluate(1)
  end

  test 'evaluate multipart rule' do
    definition = {multipart: true, part1: 'ends_in', value1: '1', operator: 'and', part2: 'does_not_end_in', value2: '11'}
    rule = Tr8n::NumericRule.create(:language => lang, :definition => definition)
    assert rule.evaluate(1)
    assert rule.evaluate(21)
    assert rule.evaluate(231)
    assert rule.evaluate(1021)
    refute rule.evaluate(2)
    refute rule.evaluate(11)
    refute rule.evaluate(211)
    refute rule.evaluate(1011)

    definition = {multipart: true, part1: 'ends_in', value1: '2,3,4', operator: 'and', part2: 'does_not_end_in', value2: '12,13,14'}
    rule = Tr8n::NumericRule.create(:language => lang, :definition => definition)
    assert rule.evaluate(2)
    assert rule.evaluate(1023)
    assert rule.evaluate(34)
    refute rule.evaluate(1013)
    refute rule.evaluate(14)
  end

  test 'to_hash' do
    definition = {multipart: true, part1: 'ends_in', value1: '2,3,4', operator: 'and', part2: 'does_not_end_in', value2: '12,13,14'}
    rule = Tr8n::NumericRule.create(:language => lang, :definition => definition)
    assert_equal({:type=>'number', :multipart=>true, :operator=>'and', :part1=>'ends_in',
                   :value1=>'2,3,4', :part2=>'does_not_end_in', :value2=>'12,13,14'}, rule.to_hash)
  end

  test 'description' do
    definition = {multipart: true, part1: 'ends_in', value1: '2,3,4', operator: 'and', part2: 'does_not_end_in', value2: '12,13,14'}
    rule = Tr8n::NumericRule.create(:language => lang, :definition => definition)
    assert_equal 'ends in 2, 3, 4, but not in 12, 13, 14', rule.description

    definition = {multipart: false, part1: 'does_not_end_in', value1: '2,3,4,5'}
    rule = Tr8n::NumericRule.create(:language => lang, :definition => definition)
    assert_equal 'does not end in 2, 3, 4, 5', rule.description
  end

private

  def lang
    @lang ||= Tr8n::Language.create!(:locale => 'elb', :english_name => 'Elbonian')
  end

end # class NumericRuleTest
