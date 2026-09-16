require 'test_helper'

class LanguageCaseTest < Tr8n::TestCase

  test 'by_id returns the case' do
    lcase = possessive_case

    assert_equal lcase, Tr8n::LanguageCase.by_id(lcase.id)
  end

  test 'by_id returns nil for an unknown id' do
    assert_nil Tr8n::LanguageCase.by_id(0)
  end

  test 'application_options' do
    assert_equal [["every word", "words"], ["entire phrase", "phrase"]],
                 Tr8n::LanguageCase.application_options
  end

  ##############################################################################
  # add_rule
  ##############################################################################

  test 'add_rule creates a rule for the case and its language' do
    lcase = possessive_case
    rule  = lcase.add_rule(:part1 => 'is', :value1 => 'Michael',
                           :operation => 'replace', :operation_value => 'Mike')

    assert_instance_of Tr8n::LanguageCaseRule, rule
    assert_equal lcase,             rule.language_case
    assert_equal lcase.language,    rule.language
    assert_equal 'is',              rule.definition[:part1]
    assert_includes lcase.reload.language_case_rules, rule
  end

  test 'add_rule appends the rule at the end' do
    lcase = lcase()

    assert_equal 0, lcase.add_rule(:part1 => 'is', :value1 => '1').position
    assert_equal 1, lcase.add_rule(:part1 => 'is', :value1 => '2').position
    assert_equal 2, lcase.add_rule(:part1 => 'is', :value1 => '3').position
  end

  test 'add_rule accepts an explicit position' do
    lcase = lcase()

    assert_equal 5, lcase.add_rule({:part1 => 'is', :value1 => '1'}, :position => 5).position
  end

  test 'add_rule uses the current translator by default' do
    init_tr8n(english.locale, translator.user)

    assert_equal translator, lcase().add_rule(:part1 => 'is', :value1 => '1').translator
  end

  test 'add_rule accepts an explicit translator' do
    other = other_translator

    assert_equal other, lcase().add_rule({:part1 => 'is', :value1 => '1'},
                                         :translator => other).translator
  end

  ##############################################################################
  # rules
  ##############################################################################

  test 'rules returns the rules ordered by position' do
    lcase = lcase()
    third = lcase.add_rule({:part1 => 'is', :value1 => '3'}, :position => 2)
    first = lcase.add_rule({:part1 => 'is', :value1 => '1'}, :position => 0)

    assert_equal [first, third], lcase.reload.rules.to_a
  end

  test 'rules is empty for an unsaved case' do
    assert_empty Tr8n::LanguageCase.new(:language => english).rules
  end

  ##############################################################################
  # evaluate_rules
  ##############################################################################

  test 'evaluate_rules returns the first matching rule' do
    lcase  = lcase()
    first  = lcase.add_rule(:part1 => 'does_not_end_in', :value1 => 's',
                            :operation => 'append', :operation_value => "'s")
    second = lcase.add_rule(:part1 => 'is', :value1 => 'Michael',
                            :operation => 'replace', :operation_value => 'Mike')

    assert second.evaluate(nil, 'Michael') # the second rule matches too, but is never reached
    assert_equal first, lcase.evaluate_rules(nil, 'Michael')
  end

  test 'evaluate_rules returns nil when no rule matches' do
    lcase = lcase()
    lcase.add_rule(:part1 => 'is', :value1 => 'Anna',
                   :operation => 'replace', :operation_value => 'Anny')

    assert_nil lcase.evaluate_rules(nil, 'Michael')
  end

  test 'evaluate_rules returns nil when the case has no rules' do
    assert_nil lcase().evaluate_rules(nil, 'Michael')
  end

  ##############################################################################
  # apply
  ##############################################################################

  test 'apply should substitute the tokens with appropriate case' do
    assert_equal "Michael's", possessive_case.apply(michael, 'Michael', {})
  end

  test 'apply with a phrase application transforms the whole value' do
    lcase = possessive_case(:application => 'phrase')

    assert_equal "Michael and Anna's", lcase.apply(michael, 'Michael and Anna', {})
  end

  test 'apply with a words application transforms every word' do
    lcase = lcase(:application => 'words')
    lcase.add_rule(:part1 => 'is', :value1 => 'Michael',
                   :operation => 'replace', :operation_value => 'Mike')

    assert_equal 'Mike and Anna', lcase.apply(michael, 'Michael and Anna', {})
  end

  # Issue 2581
  test 'apply with a phrase application ignores non word characters' do
    assert_equal "(Michael's)", possessive_case.apply(michael, '(Michael)', {})
  end

  # Issue 2581, 2587 - a Latvian genitive rule over a value with punctuation and
  # non ascii word characters
  test 'apply with a words application ignores non word characters' do
    lcase = lcase(:application => 'words')
    lcase.add_rule(:part1 => 'ends_in', :value1 => 'a',
                   :operation => 'append', :operation_value => 's')

    assert_equal '(foas / Budļevskas)', lcase.apply(michael, '(foa / Budļevska)', {})
  end

  test 'apply leaves the value alone when no rule matches' do
    lcase = lcase()
    lcase.add_rule(:part1 => 'is', :value1 => 'Anna',
                   :operation => 'replace', :operation_value => 'Anny')

    assert_equal 'Michael', lcase.apply(michael, 'Michael', {})
  end

  test 'apply preserves html tags' do
    lcase = possessive_case

    assert_equal "<b>Michael's</b>", lcase.apply(michael, '<b>Michael</b>', {})
  end

  test 'apply preserves html tags around every word' do
    lcase = lcase(:application => 'words')
    lcase.add_rule(:part1 => 'is', :value1 => 'Michael',
                   :operation => 'replace', :operation_value => 'Mike')

    assert_equal '<b>Mike</b> and <i>Anna</i>',
                 lcase.apply(michael, '<b>Michael</b> and <i>Anna</i>', {})
  end

  test 'apply picks the rule that matches the gender of the object' do
    lcase = lcase(:language => russian)
    lcase.add_rule(:gender => 'female', :part1 => 'is', :value1 => 'Sasha',
                   :operation => 'replace', :operation_value => 'Sashi')
    lcase.add_rule(:gender => 'male', :part1 => 'is', :value1 => 'Sasha',
                   :operation => 'replace', :operation_value => 'Sashe')

    assert_equal 'Sashi', lcase.apply(anna,    'Sasha', :skip_decorations => true)
    assert_equal 'Sashe', lcase.apply(michael, 'Sasha', :skip_decorations => true)
  end

  test 'apply prefers a language case value map over the rules' do
    lcase = possessive_case
    value_map('Michael', 'pos' => 'Michael!')

    assert_equal 'Michael!', lcase.apply(michael, 'Michael', {})
  end

  # a Russian dative case: some words come from the value maps, the rest from the rules
  test 'apply mixes value map words with rule driven words' do
    lcase = dative_case
    value_map('отец', {'dat' => 'отцу'},  :language => russian)
    value_map('мать', {'dat' => 'матери'}, :language => russian)

    assert_equal 'дорогому отцу/матери',
                 lcase.apply(michael, 'дорогой отец/мать', :skip_decorations => true)
  end

  # a value map is an exception: the rules are not applied to the word, even when
  # the map has nothing to say about this particular case
  test 'apply leaves the value alone when the value map has no value for the case' do
    lcase = possessive_case
    value_map('Michael', 'other' => 'Michael!')

    assert_equal 'Michael', lcase.apply(michael, 'Michael', {})
  end

  test 'apply ignores a reported language case value map' do
    lcase = possessive_case
    value_map('Michael', {'pos' => 'Michael!'}, :reported => true)

    assert_equal "Michael's", lcase.apply(michael, 'Michael', {})
  end

  test 'apply ignores the value map with ignore_language_case_exceptions' do
    lcase = possessive_case
    value_map('Michael', 'pos' => 'Michael!')

    assert_equal "Michael's",
                 lcase.apply(michael, 'Michael', :ignore_language_case_exceptions => true)
  end

  test 'apply decorates the value for an inline translator' do
    lcase = possessive_case(:language => russian)
    enable_inline_translations!

    result = lcase.apply(michael, 'Michael', {})

    assert_match(/^<span class='tr8n_language_case' case_id='#{lcase.id}'/, result)
    assert_match(/case_key='Michael'>Michael's<\/span>$/, result)
  end

  ##############################################################################
  # decorate_language_case
  ##############################################################################

  test 'decorate_language_case wraps the value in a span' do
    lcase = possessive_case(:language => russian)
    rule  = lcase.rules.first
    enable_inline_translations!

    assert_equal "<span class='tr8n_language_case' case_id='#{lcase.id}' " \
                 "rule_id='#{rule.id}' case_key='Michael'>Michael's</span>",
                 lcase.decorate_language_case('Michael', "Michael's", rule)
  end

  test 'decorate_language_case leaves the rule id blank without a rule' do
    lcase = possessive_case(:language => russian)
    enable_inline_translations!

    assert_equal "<span class='tr8n_language_case' case_id='#{lcase.id}' " \
                 "rule_id='' case_key='Michael'>Michael</span>",
                 lcase.decorate_language_case('Michael', 'Michael', nil)
  end

  test 'decorate_language_case is skipped for the default language' do
    lcase = possessive_case(:language => english)
    enable_inline_translations!(english)

    assert_equal "Michael's", lcase.decorate_language_case('Michael', "Michael's", nil)
  end

  test 'decorate_language_case is skipped with the skip_decorations option' do
    lcase = possessive_case(:language => russian)
    enable_inline_translations!

    assert_equal "Michael's",
                 lcase.decorate_language_case('Michael', "Michael's", nil, :skip_decorations => true)
  end

  test 'decorate_language_case is skipped with the skip_decorations block option' do
    lcase = possessive_case(:language => russian)
    enable_inline_translations!
    Tr8n::Config.stubs(:block_options).returns(:skip_decorations => true)

    assert_equal "Michael's", lcase.decorate_language_case('Michael', "Michael's", nil)
  end

  test 'decorate_language_case is skipped for a guest' do
    lcase = possessive_case(:language => russian)
    enable_inline_translations!
    Tr8n::Config.stubs(:current_user_is_guest?).returns(true)

    assert_equal "Michael's", lcase.decorate_language_case('Michael', "Michael's", nil)
  end

  test 'decorate_language_case is skipped for a non translator' do
    lcase = possessive_case(:language => russian)
    init_tr8n(russian.locale, User.create!(:name => 'Anonymous', :gender => 'male'))

    refute Tr8n::Config.current_user_is_translator?
    assert_equal "Michael's", lcase.decorate_language_case('Michael', "Michael's", nil)
  end

  test 'decorate_language_case is skipped when inline translations are disabled' do
    lcase = possessive_case(:language => russian)
    init_tr8n(russian.locale, translator.user)

    refute translator.enable_inline_translations?
    assert_equal "Michael's", lcase.decorate_language_case('Michael', "Michael's", nil)
  end

  ##############################################################################
  # save_with_log! / destroy_with_log!
  ##############################################################################

  test 'save_with_log! logs a new case and assigns the translator' do
    lcase = Tr8n::LanguageCase.new(:language => english, :keyword => 'pos',
                                   :application => 'phrase')

    translator.expects(:added_language_case!).with(lcase)

    assert lcase.save_with_log!(translator)
    assert_equal translator, lcase.translator
    assert lcase.persisted?
  end

  test 'save_with_log! logs an updated case and reassigns the translator' do
    lcase = possessive_case
    other = other_translator
    lcase.description = 'Indicates ownership'

    other.expects(:updated_language_case!).with(lcase)

    assert lcase.save_with_log!(other)
    assert_equal other, lcase.reload.translator
    assert_equal 'Indicates ownership', lcase.description
  end

  test 'save_with_log! does not log an unchanged case' do
    lcase = possessive_case
    other = other_translator

    other.expects(:updated_language_case!).never

    assert lcase.save_with_log!(other)
    assert_equal translator, lcase.reload.translator
  end

  test 'destroy_with_log! logs and destroys the case with its rules' do
    lcase = possessive_case
    other = other_translator

    other.expects(:deleted_language_case!).with(lcase)

    assert_difference 'Tr8n::LanguageCase.count', -1 do
      assert_difference 'Tr8n::LanguageCaseRule.count', -2 do
        lcase.destroy_with_log!(other)
      end
    end
  end

private

  def lcase(attrs = {})
    Tr8n::LanguageCase.create!({
      :language     => english,
      :translator   => translator,
      :keyword      => 'pos',
      :latin_name   => 'Possessive',
      :native_name  => 'Possessive',
      :description  => "Used to indicate possession (i.e., ownership). It is usually created by adding 's to the word",
      :application  => 'phrase'
    }.merge(attrs))
  end

  # a case with the two english possessive rules: friends' and Michael's
  def possessive_case(attrs = {})
    lcase(attrs).tap do |lcase|
      lcase.add_rule(:multipart => false, :gender => 'none',
                     :part1 => 'ends_in', :value1 => 's',
                     :operation => 'append', :operation_value => "'")
      lcase.add_rule(:multipart => false, :gender => 'none',
                     :part1 => 'does_not_end_in', :value1 => 's',
                     :operation => 'append', :operation_value => "'s")
    end
  end

  # a Russian case with the two dative rules: отцу and дорогому
  def dative_case
    lcase(:language => russian, :keyword => 'dat', :latin_name => 'Dative',
          :native_name => 'Dative', :application => 'words').tap do |lcase|
      lcase.add_rule(:multipart => false, :gender => 'none',
                     :part1 => 'ends_in',
                     :value1 => 'б, в, г, д, ж, з, к, л, м, н, п, р, с, т, ф, х, ц, ч, ш, щ',
                     :operation => 'append', :operation_value => 'у')
      lcase.add_rule(:multipart => false, :gender => 'none',
                     :part1 => 'ends_in', :value1 => 'ой',
                     :operation => 'replace', :operation_value => 'ому')
    end
  end

  def value_map(keyword, map, attrs = {})
    Tr8n::LanguageCaseValueMap.create!({
      :language   => english,
      :translator => translator,
      :keyword    => keyword,
      :map        => HashWithIndifferentAccess.new(map),
      :reported   => false
    }.merge(attrs))
  end

  def enable_inline_translations!(language = russian)
    translator.enable_inline_translations!
    init_tr8n(language.locale, translator.user)
  end

  def other_translator
    @other_translator ||= Tr8n::Translator.create!(:user => User.create!(:name => 'Bob', :gender => 'male'))
  end

  def michael
    @michael ||= stub('male', :to_s => 'Michael', :gender => 'male')
  end

  def anna
    @anna ||= stub('female', :to_s => 'Anna', :gender => 'female')
  end

end # class LanguageCaseTest
