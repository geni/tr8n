require 'test_helper'

module Tr8n
  class LanguageCasesControllerTest < ControllerTest

    test 'guest user should be redirect to homepage' do
      get :index
      assert_redirected_to Tr8n::Config.default_url
    end

    test 'logged in user should get index' do
      login!
      get :index
      assert_response :success
    end

  end # class LanguageCasesControllerTest
end  # module Tr8n