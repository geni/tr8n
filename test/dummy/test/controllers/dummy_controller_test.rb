require 'test_helper'

class DummyControllerTest < ActionDispatch::IntegrationTest

  test "index" do
    get '/'
    assert_response :success
    assert_select 'h1', 'Tr8n Dummy App'
  end

end
