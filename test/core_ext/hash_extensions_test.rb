require 'test_helper'

class HashExtensionsTest < Tr8n::TestCase
  test 'combinations' do
    hash     = {:a => [1, 2], :b => [1, 2]}
    expected = [{:a => 1, :b => 1}, {:a => 2, :b => 1}, {:a => 1, :b => 2}, {:a => 2, :b => 2}]

    assert_equal expected, hash.combinations
  end

end # class HashExtensionsTest