require 'test_helper'

module Tr8n
  module Admin
    class ForumControllerTest < ControllerTest

      # CSRF Protection Tests

      test 'controller should have CSRF protection enabled' do
        # Verify that protect_from_forgery has been called
        assert Tr8n::Admin::ForumController._process_action_callbacks.any? { |callback|
          callback.filter == :verify_authenticity_token
        }, "Admin::ForumController should have protect_from_forgery enabled"
      end

      # Note: The following routes are now protected by CSRF:
      # - DELETE /admin/forum/delete_topic
      # - DELETE /admin/forum/delete_message
      # - DELETE /admin/forum/delete_report
      #
      # In production, requests without valid CSRF tokens will be rejected.
      # In test mode, CSRF protection is disabled by default for easier testing.

    end # class ForumControllerTest
  end # module Admin
end # module Tr8n
