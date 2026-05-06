
# == Schema Information
#
# Table name: tr8n_translation_sources
#
#  id                    :integer          not null, primary key
#  completeness          :integer          default(0)
#  description           :text
#  key_count             :integer
#  name                  :string
#  source                :string
#  url                   :string
#  created_at            :datetime
#  updated_at            :datetime
#  translation_domain_id :integer
#
# Indexes
#
#  tr8n_sources_source  (source)
#
class Tr8n::TranslationSource < ApplicationRecord

  belongs_to :translation_domain

  has_many  :translation_key_sources,       :dependent => :destroy
  has_many  :translation_keys,              :through => :translation_key_sources
  has_many  :translation_source_languages,  :dependent => :destroy
  has_many  :translation_source_metrics,    :dependent => :destroy
  has_many  :component_sources,             :dependent => :destroy
  has_many  :components,                    :through => :component_sources

  alias :domain   :translation_domain
  alias :sources  :translation_key_sources
  alias :keys     :translation_keys
  alias :metrics  :translation_source_metrics

  def self.cache_key(source)
    "translation_source_#{source.to_s}"
  end

  def cache_key
    self.class.cache_key(source)
  end

  def self.find_or_create(source, url = nil)
    return source if source.is_a?(Tr8n::TranslationSource)
    source = source.to_s
    result = fetch_source(source)

    # cache broken - force re-fetch
    if result.nil?
      Tr8n::Cache.delete(cache_key(source))
      result = fetch_source(source)
    end

    raise ArgumentError.new("Failed to find or create source for: #{source}") if result.nil?

    return result
  end

  def self.fetch_source(source)
    Tr8n::Cache.fetch(cache_key(source)) do
      model = where(:source => source).first || create!(:source => source)
      model.update_attributes!(:key_count => Tr8n::TranslationKeySource.where(:translation_source_id => model.id).count)
      model
    end
  end

  def update_metrics!(language = Tr8n::Config.current_language)
    metric = total_metric(language)
    Tr8n::OfflineTask.schedule(metric.class.name, :update_metrics_offline, {
                               :translation_source_metric_id => metric.id,
    })
  end

  def after_destroy
    Tr8n::Cache.delete(cache_key)
  end

  def after_save
    Tr8n::Cache.delete(cache_key)
  end

  def total_metric(language = Tr8n::Config.current_language)
    Tr8n::TranslationSourceMetric.find_or_create(self, language)
  end

  def self.options
    @sources = Tr8n::TranslationSource.order("source asc").collect {|src| [src.source, src.source]}
  end

  def title
    return source if name.blank?
    name
  end

  def name_and_source
    return source if name.blank?
    "#{name} (#{source})"
  end

  def translator_authorized?(translator = Tr8n::Config.current_translator)
    components.each do |comp|
      return false unless comp.translator_authorized?(translator)
    end
    true
  end

end
