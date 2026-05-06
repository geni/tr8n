
class Tr8n::LanguageFilter < Tr8n::BaseFilter

  def definition
    defs = super  
    defs[:fallback_language_id][:is] = :list
    defs[:fallback_language_id][:is_not] = :list
    defs
  end
  
  def value_options_for(criteria_key)
    if criteria_key == :fallback_language_id
      return Tr8n::Language.filter_options 
    end

    return []
  end

  def default_order
    'english_name'
  end
  
  def default_order_type
    'asc'
  end

  def default_filters
    super + [
      ["Enabled Languages", "enabled"],
      ["Disabled Languages", "disabled"],
      ["Left-to-Right Languages", "left"],
      ["Right-to-Left Languages", "right"]
    ]
  end

  def default_filter_conditions(key)
    super_conditions = super(key)
    return super_conditions if super_conditions

    case key
      when "enabled"
        return [:enabled, :is, '1']
      when "disabled"
        return [:enabled, :is, '0']
      when "left"
        return [:right_to_left, :is, '0']
      when "right"
        return [:right_to_left, :is, '1']
    end
    
  end

end
