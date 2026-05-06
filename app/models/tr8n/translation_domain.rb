
# == Schema Information
#
# Table name: tr8n_translation_domains
#
#  id           :integer          not null, primary key
#  description  :string
#  name         :string
#  source_count :integer          default(0)
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_tr8n_translation_domains_on_name  (name) UNIQUE
#
class Tr8n::TranslationDomain < ApplicationRecord

  has_many    :translation_sources,     :dependent => :destroy
  has_many    :translation_key_sources, :through => :translation_sources
  has_many    :translation_keys,        :through => :translation_key_sources

  alias :sources      :translation_sources
  alias :key_sources  :translation_key_sources
  alias :keys         :translation_keys

  def self.cache_key(domain_name)
    "translation_domain_#{domain_name}"
  end

  def cache_key
    self.class.cache_key(name)
  end

  def self.find_or_create(url = nil)
    domain_name = URI.parse(url || 'localhost').host || 'localhost'
    Tr8n::Cache.fetch(cache_key(domain_name)) do
      find_by_name(domain_name) || create(:name => domain_name)
    end
  end

  def after_save
    Tr8n::Cache.delete(cache_key)
  end

  def after_destroy
    Tr8n::Cache.delete(cache_key)
  end

end
