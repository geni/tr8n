
class Tr8n::TranslatorReportFilter < Tr8n::BaseFilter

  def inner_joins
    [["Tr8n::Translator", :translator_id]]
  end

end
