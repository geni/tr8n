
class Tr8n::TranslatorFilter < Tr8n::BaseFilter

  def default_filters
    super + [
      ["Watchlist", "watchlist"]
    ]
  end

  def default_filter_conditions(key)
    super_conditions = super(key)
    return super_conditions if super_conditions

    case key
      when "watchlist"
        return [:reported, :is, '1']
    end
  end
  
  def default_filter_if_empty
    "created_today"
  end
  
end
