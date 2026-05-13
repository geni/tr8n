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

    # CSRF Protection Tests
    # These tests verify that CSRF protection is enabled by checking that
    # protect_from_forgery is declared on the controller

    test 'controller should have CSRF protection enabled' do
      # Verify that protect_from_forgery has been called
      assert Tr8n::PhrasesController._process_action_callbacks.any? { |callback|
        callback.filter == :verify_authenticity_token
      }, "PhrasesController should have protect_from_forgery enabled"
    end

    # Note: The following routes are now protected by CSRF:
    # - POST /phrases/translate
    # - POST /phrases/update
    # - POST /phrases/submit_comment
    # - POST /phrases/delete_comment
    #
    # In production, requests without valid CSRF tokens will be rejected.
    # In test mode, CSRF protection is disabled by default for easier testing.

  end # class PhrasesControllerTest
end # module Tr8n