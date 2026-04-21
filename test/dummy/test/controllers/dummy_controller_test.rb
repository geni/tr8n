require "test_helper"

class DummyControllerTest < ActionDispatch::IntegrationTest

  test 'index' do
    get '/'
    assert_response :success
  end
end
