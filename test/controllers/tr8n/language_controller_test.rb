require 'test_helper'

module Tr8n
  class LanguageControllerTest < ControllerTest

    test 'redirect the guest user to homepage' do
      get :index
      assert_redirected_to Tr8n::Config.default_url
    end

    test 'logged in user get index' do
      login!
      get :index
      assert_response :success
    end

  end # class LanguageControllerTest
end # module Tr8n