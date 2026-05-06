
class Tr8n::LanguageCaseValueMapFilter < Tr8n::BaseFilter

  def definition
    defs = super  
    defs[:language_id][:is] = :list
    defs[:language_id][:is_not] = :list
    defs
  end
  
  def value_options_for(criteria_key)
    if criteria_key == :language_id
      return Tr8n::Language.filter_options 
    end

    return []
  end

end
