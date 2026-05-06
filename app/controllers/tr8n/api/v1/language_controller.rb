
class Tr8n::Api::V1::LanguageController < Tr8n::Api::V1::BaseController


  # for ssl access to the translator - using ssl_requirement plugin
  ssl_allowed :translate  if respond_to?(:ssl_allowed)

  # returns a list of all languages
  def index
    languages = []
    Tr8n::Language.enabled_languages.each do |lang|
      languages << {:locale => lang.locale, :name => lang.full_name}
    end
    sanitize_api_response({:languages => languages})
  end

  def translate
    language = Tr8n::Language.for(params[:language]) || tr8n_current_language
    source = CGI.unescape(params[:source] || "API")

    return sanitize_api_response(translate_phrase(language, params, {:source => source, :api => :translate})) if params[:label]

    # API signature
    # {:source => "", :language => "", :phrases => [{:label => ""}]}

    # get all phrases for the specified source
    # this can be used by a parallel application or a JavaScript Client SDK that needs to build a page cache
    if params[:batch] == "true" or params[:cache] == "true"
      if params[:sources].blank? and params[:source].blank?
        return sanitize_api_response({"error" => "No source/sources have been provided for the batch request."})
      end

      source_names = params[:sources] || [params[:source]]
      sources = Tr8n::TranslationSource.where(["source in (?)", source_names])
      source_ids = sources.collect{|source| source.id}

      if source_ids.empty?
        conditions = ["1=2"]
      else
        conditions = ["(id in (select distinct(translation_key_id) from tr8n_translation_key_sources where translation_source_id in (?)))"]
        conditions << source_ids.uniq
      end

      translations = []
      Tr8n::TranslationKey.where(conditions).each_with_index do |tkey, index|
        trn = tkey.translate(language, {}, {:api => :cache})
        translations << trn
      end

      if params[:sdk_jsvar]
        return render(:text => "#{params[:sdk_jsvar]}.updateTranslations(#{translations.to_json});", :content_type => "text/javascript")
      end

      return sanitize_api_response({:phrases => translations})
    elsif params[:phrases]

      phrases = []
      begin
        phrases = HashWithIndifferentAccess.new({:data => JSON.parse(params[:phrases])})[:data]
      rescue Exception => ex
        return sanitize_api_response({"error" => "Invalid request. JSON parsing failed: #{ex.message}"})
      end

      translations = []
      phrases.each do |phrase|
        phrase = {:label => phrase} if phrase.is_a?(String)
        translations << translate_phrase(language, phrase, {:source => source, :api => :translate})
      end

      return sanitize_api_response({:phrases => translations})
    end

    sanitize_api_response(:phrases => {})
  rescue Tr8n::KeyRegistrationException => ex
    sanitize_api_response({"error" => ex.message})
  end

private

  def translate_phrase(language, phrase, opts = {})
    return "" if phrase[:label].strip.blank?
    translation_key = Tr8n::TranslationKey.find_or_create(phrase[:label], phrase[:description], opts)
    translation_key.translate(language, {}, opts)
  end

end