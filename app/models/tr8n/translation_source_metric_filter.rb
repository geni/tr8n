
class Tr8n::TranslationSourceMetricFilter < Tr8n::BaseFilter

  def inner_joins
    [["Tr8n::Language", :language_id], ["Tr8n::TranslationSource", :translation_source_id]]
  end

end
