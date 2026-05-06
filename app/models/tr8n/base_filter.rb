
class Tr8n::BaseFilter < WillFilter::Filter

  def definition
    meta = super
    meta.keys.each do |key|
      parts = key.to_s.split(".")
      next unless parts.last.index("language_id")
      meta[key][:is] = :list
      meta[key][:is_not] = :list
    end
    meta
  end

  def value_options_for(criteria_key)
    parts = criteria_key.to_s.split(".")
    if parts.last.index("language_id")
      return Tr8n::Language.filter_options
    end

    return []
  end

  def default_filters
    [
      ["Created Today", "created_today"],
      ["Updated Today", "updated_today"]
    ]
  end

  def default_filter_conditions(key)
    return [:created_at, :is_on, Date.today] if (key == "created_today")
    return [:updated_at, :is_on, Date.today] if (key == "updated_today")
  end

  def default_order
    'created_at'
  end

  def default_order_type
    'desc'
  end

end
