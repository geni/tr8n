
class Tr8n::TranslationKeyLockFilter < Tr8n::BaseFilter

  def inner_joins
    [["Tr8n::Language", :language_id], ["Tr8n::TranslationKey", :translation_key_id], ["Tr8n::Translator", :translator_id]]
  end

end
