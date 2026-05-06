
# == Schema Information
#
# Table name: tr8n_language_case_rules
#
#  id               :integer          not null, primary key
#  definition       :text             not null
#  position         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  language_case_id :integer          not null
#  language_id      :integer
#  translator_id    :bigint
#
# Indexes
#
#  tr8n_lcr_case_id        (language_case_id)
#  tr8n_lcr_lang_id        (language_id)
#  tr8n_lcr_translator_id  (translator_id)
#
class Tr8n::LanguageCaseRule < ApplicationRecord

  belongs_to :language_case
  belongs_to :language
  belongs_to :translator

  serialize :definition
  validates_presence_of :definition

  def definition=(value)
    write_attribute(:definition, HashWithIndifferentAccess.new(value || {}))
  end

  def self.by_id(id)
    Tr8n::Cache.fetch("language_case_rule_#{id}") do
      find_by_id(id)
    end
  end

  def self.gender_options
    [["not applicable", "none"], ["unknown", "unknown"], ["male", "male"], ["female", "female"]]
  end

  def self.condition_options(with_if = false)
    opts = [["starts with", "starts_with"], ["does not start with", "does_not_start_with"],
     ["ends in", "ends_in"], ["does not end in", "does_not_end_in"],
     ["is", "is"], ["is not", "is_not"]]
    return opts unless with_if
    opts.each do |opt|
      opt[0] = "if #{opt[0]}"
    end
    opts
  end

  def self.operation_options
    [["replace with", "replace"], ["prepand", "prepand"], ["append", "append"]]
  end

  def self.operator_options
    [["and", "and"], ["or", "or"]]
  end

  def evaluate(object, value)
    if definition["gender"] != "none"
      object_gender = Tr8n::GenderRule.gender_token_value(object)
      return false if definition["gender"] == "male"    and object_gender != Tr8n::GenderRule.gender_object_value_for("male")
      return false if definition["gender"] == "female"  and object_gender != Tr8n::GenderRule.gender_object_value_for("female")
      return false if definition["gender"] == "unknown" and object_gender != Tr8n::GenderRule.gender_object_value_for("unknown")
    end

    result1 = evaluate_part(value, 1)
    if definition["multipart"] == "true"
      result2 = evaluate_part(value, 2)
      return false if definition["operator"] == "and" and !(result1 and result2)
      return false if definition["operator"] == "or"  and !(result1 or result2)
    end

    return result1
  end

  def evaluate_part(token_value, index)
    values = sanitize_values(definition["value#{index}"])

    case definition["part#{index}"]
      when "starts_with"
        values.each do |value|
          return true if token_value.to_s =~ /^[\P{word}]*#{value.to_s}/
        end
        return false
      when "does_not_start_with"
        values.each do |value|
          return false if token_value.to_s =~ /^[\P{word}]*#{value.to_s}/
        end
        return true
      when "ends_in"
        values.each do |value|
          return true if token_value.to_s =~ /#{value.to_s}[\P{word}]*$/
        end
        return false
      when "does_not_end_in"
        values.each do |value|
          return false if token_value.to_s =~ /#{value.to_s}[\P{word}]*$/
        end
        return true
      when "is"
        return values.include?(token_value)
      when "is_not"
        return !values.include?(token_value)
    end

    false
  end

  def apply(value)
    values = sanitize_values(definition["value1"])
    regex = values.join('|')
    case definition["operation"]
      when "replace"
        if definition["part1"] == "starts_with"
          return value.gsub(/\b(#{regex})/, definition["operation_value"])
        elsif definition["part1"] == "is"
          return definition["operation_value"]
        elsif definition["part1"] == "ends_in"
          return value.gsub(/(#{regex})\b/, definition["operation_value"])
        end
      when "prepand"
        return value.sub(/^(\P{word}*)/, "\\1#{definition["operation_value"]}")
      when "append"
        return value.sub(/(\P{word}*)$/, "#{definition["operation_value"]}\\1")
    end

    value
  end

  def sanitize_values(values)
    return [] unless values
    values.split(",").collect{|val| val.strip}
  end

  def humanize_values(values)
    sanitize_values(values).join(", ")
  end

  def description
    return "undefined rule" if definition.blank?

    desc = "If"
    if definition["gender"] != "none"
      desc << " subject"
      if ["male", "female"].include?(definition["gender"])
        desc << " is a <strong>#{definition["gender"]}</strong>"
      else
        desc << " <strong>has an unknown gender</strong>"
      end
    end
    desc << " and" unless desc == "If"
    desc << " token value"
    desc << describe_part(1)

    if definition["multipart"] == "true"
      desc << " " << definition["operator"]
      desc << describe_part(2)
    end

    desc << ", then"
    case definition["operation"]
      when "replace" then desc << " replace it with"
      when "prepand" then desc << " prepand the value with"
      when "append" then desc << " append the value with"
    end
    desc << " <strong>'" << humanize_values(definition["operation_value"]) << "'</strong> "
  end

  def describe_part(index)
    desc = ""
    case definition["part#{index}"]
      when "starts_with" then desc << " starts with"
      when "does_not_start_with" then desc << " does not start with"
      when "ends_in" then desc << " ends in"
      when "does_not_end_in" then desc << " does not end in"
      when "is" then desc << " is"
      when "is_not" then desc << " is not"
    end
    desc << " <strong>'" << humanize_values(definition["value#{index}"]) << "'</strong>"
  end

end
