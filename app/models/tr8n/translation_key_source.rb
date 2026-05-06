
# == Schema Information
#
# Table name: tr8n_translation_key_sources
#
#  id                    :integer          not null, primary key
#  details               :text
#  created_at            :datetime
#  updated_at            :datetime
#  translation_key_id    :integer          not null
#  translation_source_id :integer          not null
#
# Indexes
#
#  tr8n_trans_keys_key_id     (translation_key_id)
#  tr8n_trans_keys_source_id  (translation_source_id)
#
class Tr8n::TranslationKeySource < ApplicationRecord

  belongs_to :translation_source
  belongs_to :translation_key

  alias :source :translation_source
  alias :key :translation_key

  serialize :details

  def self.cache_key(translation_key_id, translation_source_id)
    "translation_key_source_#{translation_key_id}_#{translation_source_id}"
  end

  def cache_key
    self.class.cache_key(translation_key_id, translation_source_id)
  end

  def self.find_or_create(translation_key, translation_source)
    raise ArgumentError.new("translation_key cannot be nil")    if translation_key.nil?
    raise ArgumentError.new("translation_source cannot be nil") if translation_source.nil?

    Tr8n::Cache.fetch(cache_key(translation_key.id, translation_source.id)) do
      tks = where(translation_key_id: translation_key.id, translation_source_id: translation_source.id).first
      tks ||= begin
        translation_source.touch
        create!(:translation_key => translation_key, :translation_source => translation_source)
      end
    end
  end

  def after_destroy
    Tr8n::Cache.delete(cache_key)
  end

  def update_details!(options)
    return unless options[:caller_key]

    self.details ||= {}
    return if details[options[:caller_key]]

    details[options[:caller_key]] = options[:caller]
    save
  end

end
