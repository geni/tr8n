require 'test_helper'

class ComponentTest < Tr8n::TestCase

  test 'cache_key' do
    assert_equal 'component_mobile', Tr8n::Component.cache_key('mobile')
    assert_equal 'component_mobile', Tr8n::Component.new(:key => 'mobile').cache_key
  end

  test 'find_or_create creates a new restricted component' do
    comp = Tr8n::Component.find_or_create('mobile')

    assert_equal 'mobile',     comp.key
    assert_equal 'restricted', comp.state
    assert comp.restricted?
  end

  test 'find_or_create returns the existing component' do
    comp = Tr8n::Component.find_or_create('mobile')

    assert_no_difference 'Tr8n::Component.count' do
      assert_equal comp, Tr8n::Component.find_or_create('mobile')
    end
  end

  test 'find_or_create with a symbol key' do
    comp = Tr8n::Component.find_or_create(:mobile)

    assert_equal 'mobile', comp.key
    assert_equal comp, Tr8n::Component.find_or_create('mobile')
  end

  test 'find_or_create with a component' do
    comp = Tr8n::Component.find_or_create('mobile')

    assert_no_difference 'Tr8n::Component.count' do
      assert_equal comp, Tr8n::Component.find_or_create(comp)
    end
  end

  test 'find_or_create uses the cache' do
    comp = Tr8n::Component.find_or_create('mobile')

    Tr8n::Cache.expects(:fetch).with('component_mobile').returns(comp)

    assert_equal comp, Tr8n::Component.find_or_create('mobile')
  end

end # ComponentTest
