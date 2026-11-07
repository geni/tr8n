require 'test_helper'

class ComponentSourceTest < Tr8n::TestCase

  test 'find_or_create creates the join row' do
    cs = Tr8n::ComponentSource.find_or_create(component, source)

    assert_equal component.id, cs.component_id
    assert_equal source.id,    cs.translation_source_id
  end

  test 'find_or_create returns the existing join row' do
    cs = Tr8n::ComponentSource.find_or_create(component, source)

    assert_no_difference 'Tr8n::ComponentSource.count' do
      assert_equal cs, Tr8n::ComponentSource.find_or_create(component, source)
    end
  end

  test 'find_or_create keeps each component/source pair apart' do
    cs    = Tr8n::ComponentSource.find_or_create(component, source)
    other = Tr8n::ComponentSource.find_or_create(component, Tr8n::TranslationSource.find_or_create('emails/join_email'))

    refute_equal cs, other
    assert_equal 2, Tr8n::ComponentSource.where(:component_id => component.id).count
  end

private

  def component
    @component ||= Tr8n::Component.find_or_create('mobile')
  end

  def source
    @source ||= Tr8n::TranslationSource.find_or_create('emails/account_closed_email')
  end

end # ComponentSourceTest
