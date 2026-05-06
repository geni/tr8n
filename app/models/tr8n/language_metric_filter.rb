
class Tr8n::LanguageMetricFilter < Tr8n::BaseFilter

  def definition
    defs = super  
    defs[:language_id][:is] = :list
    defs[:language_id][:is_not] = :list
    defs[:type][:is] = :list
    defs[:type][:is_not] = :list
    defs
  end
  
  def value_options_for(criteria_key)
    if criteria_key == :language_id
      return Tr8n::Language.filter_options 
    end

    if criteria_key == :type
      return ["DailyLanguageMetric", "MonthlyLanguageMetric", "TotalLanguageMetric"]
    end

    return []
  end

  def default_filters
    super + [
      ["Totals", "totals"],
    ]
  end

  def default_filter_conditions(key)
    super_conditions = super(key)
    return super_conditions if super_conditions
 
    case key
      when "totals"
        return [:type, :is, "TotalLanguageMetric"]
    end   
  end

end
