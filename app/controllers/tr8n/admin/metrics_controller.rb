
class Tr8n::Admin::MetricsController < Tr8n::Admin::BaseController


  def index
    @metrics = Tr8n::TranslationSourceMetric.filter(:params => params, :filter => Tr8n::TranslationSourceMetricFilter)
  end

  def charts

  end

  def languages
    @metrics = Tr8n::LanguageMetric.filter(:params => params, :filter => Tr8n::LanguageMetricFilter)
  end

  def translators
    @metrics = Tr8n::TranslatorMetric.filter(:params => params, :filter => Tr8n::TranslatorMetricFilter)
  end

  def top_translators
    @languages = Tr8n::Language.enabled_languages
  end

end