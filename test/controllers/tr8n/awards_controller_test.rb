require 'test_helper'

module Tr8n
  class AwardsControllerTest < ControllerTest

    test 'guest user should be redirect to homepage' do
      get :index
      assert_redirected_to Tr8n::Config.default_url
    end

    test 'logged in user get index' do
      login!
      get :index
      assert_response :success
    end

  end  # class AwardsControllerTest
end # module Tr8n