
class Tr8n::TranslatorMetricFilter < Tr8n::BaseFilter

  def inner_joins
    [["Tr8n::Language", :language_id], ["Tr8n::Translator", :translator_id]]
  end

  def default_order
    'updated_at'
  end

  def default_filter_if_empty
    "updated_today"
  end

end
