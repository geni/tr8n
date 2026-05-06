
class Tr8n::LanguageRuleFilter < Tr8n::BaseFilter
  
  def inner_joins
    [["Tr8n::Language", :language_id], ["Tr8n::Translator", :translator_id]]
  end

  def definition
    defs = super  
    defs[:type][:is] = :list
    defs[:type][:is_not] = :list
    defs
  end
  
  def value_options_for(criteria_key)
    if criteria_key == :type
      return Tr8n::Config.language_rule_classes.collect{|cls| cls.name.split('::').last}
    end

    return super
  end

end
