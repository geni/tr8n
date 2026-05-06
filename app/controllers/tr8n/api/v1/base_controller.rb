
class Tr8n::Api::V1::BaseController < ApplicationController


  before_filter :check_api_enabled


  if Tr8n::Config.api_skip_before_filters.any?
    skip_before_filter *Tr8n::Config.api_skip_before_filters
  end

  if Tr8n::Config.api_before_filters.any?
    before_filter *Tr8n::Config.api_before_filters
  end

  if Tr8n::Config.api_after_filters.any?
    after_filter *Tr8n::Config.api_after_filters
  end

private

  def check_api_enabled
    sanitize_api_response({"error" => "Api is disabled"}) unless Tr8n::Config.enable_api?
  end

  def check_guest_user
    sanitize_api_response({:guest => true}) if tr8n_current_user_is_guest?
  end

  def tr8n_current_user
    Tr8n::Config.current_user
  end
  helper_method :tr8n_current_user

  def tr8n_current_language
    Tr8n::Config.current_language
  end
  helper_method :tr8n_current_language

  def tr8n_default_language
    Tr8n::Config.default_language
  end
  helper_method :tr8n_default_language

  def tr8n_current_translator
    Tr8n::Config.current_translator
  end
  helper_method :tr8n_current_translator

  def tr8n_current_user_is_admin?
    Tr8n::Config.current_user_is_admin?
  end
  helper_method :tr8n_current_user_is_admin?

  def tr8n_current_user_is_translator?
    Tr8n::Config.current_user_is_translator?
  end
  helper_method :tr8n_current_user_is_translator?

  def tr8n_current_user_is_manager?
    return false unless Tr8n::Config.current_user_is_translator?
    tr8n_current_translator.manager?
  end
  helper_method :tr8n_current_user_is_manager?

  def tr8n_current_user_is_guest?
    Tr8n::Config.current_user_is_guest?
  end
  helper_method :tr8n_current_user_is_guest?

  def sanitize_label(label)
    label.strip
  end

  def sanitize_api_response(response)
    if Tr8n::Config.api[:response_encoding] == "xml"
      render(:text => response.to_xml)
    else
      render(:text => response.to_json)
    end
  end

end