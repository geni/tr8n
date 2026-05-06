
class Tr8n::TranslatorLogFilter < Tr8n::BaseFilter

  def inner_joins
    [["Tr8n::Translator", :translator_id]]
  end

  def definition
    defs = super  
    defs[:action][:is] = :list
    defs[:action][:is_not] = :list
    defs
  end

  def value_options_for(criteria_key)
    if criteria_key == :action
      return Tr8n::TranslatorLog::ACTIONS
    end

    return []
  end
  
  def default_filter_if_empty
    "created_today"
  end
  
end
