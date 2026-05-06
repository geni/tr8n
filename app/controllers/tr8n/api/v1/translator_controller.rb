
class Tr8n::Api::V1::TranslatorController < Tr8n::Api::V1::BaseController


  def index
    return sanitize_api_response({:guest => true}) if tr8n_current_user_is_guest?

    sanitize_api_response({:guest => false, :name => tr8n_current_translator.name})
  end

end