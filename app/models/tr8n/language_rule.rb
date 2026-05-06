
# == Schema Information
#
# Table name: tr8n_language_rules
#
#  id            :integer          not null, primary key
#  definition    :text
#  type          :string
#  created_at    :datetime
#  updated_at    :datetime
#  language_id   :integer          not null
#  translator_id :integer
#
# Indexes
#
#  index_tr8n_language_rules_on_language_id                    (language_id)
#  index_tr8n_language_rules_on_language_id_and_translator_id  (language_id,translator_id)
#
class Tr8n::LanguageRule < ApplicationRecord

  belongs_to :language
  belongs_to :translator

  serialize :definition

  def self.by_id(rule_id)
    Tr8n::Cache.fetch("language_rule_#{rule_id}") do
      find_by_id(rule_id)
    end
  end

  def self.for(language)
    find(:all, :conditions => ["language_id = ?", language.id])
  end

  def self.options
    @options ||= Tr8n::Config.language_rule_classes.collect{|kls| [kls.dependency_label, kls.name]}
  end

  def self.suffixes
    []
  end

  def self.dependant?(token)
    token.dependency == dependency or suffixes.include?(token.suffix)
  end

  def self.dependency
    raise Tr8n::Exception.new("This method must be implemented in the extending rule")
  end

  def self.keyword
    dependency
  end

  def self.dependency_label
    dependency
  end

  def self.sanitize_values(values)
    return [] unless values
    values.split(",").collect{|val| val.strip}
  end

  def self.humanize_values(values)
    sanitize_values(values).join(", ")
  end

  def evaluate(token_value)
    raise Tr8n::Exception.new("This method must be implemented in the extending rule")
  end

  def description
    raise Tr8n::Exception.new("This method must be implemented in the extending rule")
  end

  def token_description
    raise Tr8n::Exception.new("This method must be implemented in the extending rule")
  end

  def self.transformable?
    true
  end

  def save_with_log!(new_translator)
    if self.id
      if changed?
        self.translator = new_translator
        translator.updated_language_rule!(self)
      end
    else
      self.translator = new_translator
      translator.added_language_rule!(self)
    end

    save
  end

  def destroy_with_log!(new_translator)
    new_translator.deleted_language_rule!(self)

    destroy
  end

  def after_save
    Tr8n::Cache.delete("language_rule_#{id}")
  end

  def after_destroy
    Tr8n::Cache.delete("language_rule_#{id}")
  end

  ###############################################################
  ## Synchronization Methods
  ###############################################################
  def to_sync_hash(token, opts = {})
    {
      "token" => token,
      "type" => self.class.keyword,
      "definition" => definition
    }
  end

  def self.create_from_sync_hash(lang, translator, rule_hash, opts = {})
    return unless rule_hash["token"] and rule_hash["type"] and rule_hash["definition"]

    rule_class = Tr8n::Config.language_rule_dependencies[rule_hash["type"]]
    return unless rule_class # unsupported rule type, skip this completely

    rule_class.for(lang).each do |rule|
      return rule if rule.definition == rule_hash["definition"]
    end

    rule_class.create(:language => lang, :translator => translator, :definition => rule_hash["definition"])
  end

end
