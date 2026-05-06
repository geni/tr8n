
# == Schema Information
#
# Table name: tr8n_components
#
#  id             :integer          not null, primary key
#  description    :string
#  key            :string
#  name           :string
#  state          :string
#  created_at     :datetime
#  updated_at     :datetime
#  application_id :integer
#
# Indexes
#
#  tr8n_comp_app_id  (application_id)
#  tr8n_comp_key     (key)
#
class Tr8n::Component < ApplicationRecord

  belongs_to :application

  has_many :component_sources,       :dependent => :destroy
  has_many :translation_sources,     :through => :component_sources
  has_many :translation_key_sources, :through => :translation_sources
  has_many :translation_keys,        :through => :translation_key_sources

  has_many :component_languages, :dependent => :destroy
  has_many :languages,           :through => :component_languages

  has_many :component_translators, :dependent => :destroy
  has_many :translators,           :through => :component_translators

  alias :sources :translation_sources

  def self.cache_key(key)
    "component_#{key.to_s}"
  end

  def cache_key
    self.class.cache_key(key)
  end

  def self.find_or_create(key)
    return component if key.is_a?(Tr8n::Component)
    key = key.to_s

    Tr8n::Cache.fetch(cache_key(key)) do
      find(:first, :conditions => ["key = ?", key.to_s]) || create(:key => key.to_s, :state => "restricted")
    end
  end

  def self.state_options
    ["live", "restricted"]
  end

  def live?
    state == "live"
  end

  def restricted?
    state == "restricted"
  end

  def translator_authorized?(translator = Tr8n::Config.current_translator)
    return true unless restricted?
    translators.include?(translator)
  end

  def title
    return key if name.blank?
    name
  end

  def name_and_key
    return key if name.blank?
    "#{name} (#{key})"
  end

  def after_destroy
    Tr8n::Cache.delete(cache_key)
  end

  def after_save
    Tr8n::Cache.delete(cache_key)
  end

end
