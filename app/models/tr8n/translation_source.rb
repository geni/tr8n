#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

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

  has_one   :translation_domain

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
      model.update!(:key_count => Tr8n::TranslationKeySource.where(:translation_source_id => model.id).count)
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
