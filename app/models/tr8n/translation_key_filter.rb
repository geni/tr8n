
class Tr8n::TranslationKeyFilter < Tr8n::BaseFilter
  
  def default_filters
    super + [
      ["Verified Keys", "verified"],
      ["Unverified Keys", "unverified"]
    ]
  end

  def default_filter_conditions(key)
    super_conditions = super(key)
    return super_conditions if super_conditions

    case key
      when "verified"
        return [:verified_at, :is_provided]
      when "unverified"
        return [:verified_at, :is_not_provided]
    end
  end
  
end
