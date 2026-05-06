module Tr8n
  module Admin
    # TODO rename to AdminController
    class BaseController < Tr8n::BaseController

      if Tr8n::Config.admin_helpers.any?
        helper *Tr8n::Config.admin_helpers
      end

      before_filter :validate_admin

      layout Tr8n::Config.site_info[:admin_layout]

    private

      def validate_tr8n_enabled
        # don't do anything for admin pages
      end

      def validate_current_user
        # don't do anything for admin pages
      end

      def tr8n_admin_tabs
        [
            {'title' => 'Applications', 'description' => 'Admin tab', 'link' => admin_applications_path},
            {'title' => 'Languages', 'description' => 'Admin tab', 'link' => admin_language_path},
            {'title' => 'Translation Keys', 'description' => 'Admin tab', 'link' => admin_translation_key_path},
            {'title' => 'Translations', 'description' => 'Admin tab', 'link' => admin_translation_path},
            {'title' => 'Translators', 'description' => 'Admin tab', 'link' => admin_translator_path},
            {'title' => 'Glossary', 'description' => 'Admin tab', 'link' => admin_glossary_path},
            {'title' => 'Forum', 'description' => 'Admin tab', 'link' => admin_forum_path},
            {'title' => 'Metrics', 'description' => 'Metrics tab', 'link' => admin_metrics_path},
            {'title' => 'Client SDK', 'description' => 'Admin tab', 'link' => admin_clientsdk_path}
        ]
      end
      helper_method :tr8n_admin_tabs

      def validate_admin
        return if Tr8n::Config.env == 'development'

        unless tr8n_current_user_is_admin?
          trfe("You must be an admin in order to view this section of the site")
          redirect_to_site_default_url
        end
      end

    end # class BaseController
  end # module Admin
end # module Tr8n