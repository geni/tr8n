require 'test_helper'

module Tr8n
  class GlossaryControllerTest < ControllerTest

    test 'guest user should be redirected to homepage' do
      get :index
      assert_redirected_to Tr8n::Config.default_url
    end

    test 'logged in user should get index' do
      login!
      get :index
      assert_response :success
    end

  end  # class GlossaryControllerTest
end # module Tr8n