
class Tr8n::TranslationKeySourceFilter < Tr8n::BaseFilter

  def inner_joins
    [["Tr8n::TranslationKey", :translation_key_id], ["Tr8n::TranslationSource", :translation_source_id]]
  end

end
