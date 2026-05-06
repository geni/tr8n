require 'test_helper'

class LanguageCaseTest < Tr8n::TestCase

  test 'apply should substitute the tokens with appropriate case' do
    init_tr8n
    lcase = Tr8n::LanguageCase.create!(
      language:     english,
      translator:   translator,
      keyword:      'pos',
      latin_name:   'Possessive',
      native_name:  'Possessive',
      description:  "Used to indicate possession (i.e., ownership). It is usually created by adding 's to the word",
      application:  'phrase'
    )

    lcase.add_rule({
        multipart: false,
        gender: 'none',
        part1: 'ends_in',
        value1: 's',
        operation: 'append',
        operation_value: "'"
    })
    lcase.add_rule({
        multipart: false,
        gender: 'none',
        part1: 'does_not_end_in',
        value1: 's',
        operation: 'append',
        operation_value: "'s"
    })

    michael = User.create!(:name => 'Michael', :gender => 'male')

    assert_equal "Michael's", lcase.apply(michael, 'Michael', {})
  end

end # class LanguageCaseTest
