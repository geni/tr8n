require 'test_helper'

module Tr8n
  class PhrasesControllerTest < ControllerTest

    test 'guest user should be redirected to homepage' do
	    get :index
      assert_redirected_to Tr8n::Config.default_url
	  end

	  test 'logged in user should be able to access index' do
      login!
	    get :index
	    assert_response :success
	  end

  end # class PhrasesControllerTest
end # module Tr8n