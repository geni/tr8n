
# == Schema Information
#
# Table name: tr8n_translation_source_metrics
#
#  id                    :integer          not null, primary key
#  key_count             :integer          default(0)
#  locked_key_count      :integer          default(0)
#  translated_key_count  :integer          default(0)
#  translation_count     :integer          default(0)
#  created_at            :datetime
#  updated_at            :datetime
#  language_id           :integer          not null
#  translation_source_id :integer          not null
#
# Indexes
#
#  tr8n_tsm_on_translation_source_id_and_language_id  (translation_source_id,language_id)
#
class Tr8n::TranslationSourceMetric < ApplicationRecord

  belongs_to  :translation_source
  belongs_to  :language

  def self.find_or_create(translation_source, language = Tr8n::Config.current_language)
    translation_source_metric = where(:translation_source_id => translation_source.id, :language_id => language.id).first
    translation_source_metric ||= begin
      create(:translation_source => translation_source, :language => language)
    end
  end

  def update_metrics!
    self.key_count = Tr8n::TranslationKey
        .where(['tks.translation_source_id = ?', translation_source_id])
        .joins('JOIN tr8n_translation_key_sources AS tks ON tr8n_translation_keys.id = tks.translation_key_id')
        .distinct.count('tr8n_translation_keys.id')

    self.translation_count = Tr8n::Translation
        .where(['tr8n_translations.language_id = ? and tr8n_translation_key_sources.translation_source_id = ?', language_id, translation_source_id])
        .joins('JOIN tr8n_translation_key_sources ON tr8n_translation_key_sources.translation_key_id = tr8n_translations.translation_key_id')
        .distinct.count('tr8n_translations.id'
    )

    self.locked_key_count = Tr8n::TranslationKey
        .where(['tkl.language_id = ? and tks.translation_source_id = ? and tkl.locked = ?', language_id, translation_source_id, true])
        .joins('JOIN tr8n_translation_key_locks AS tkl ON tr8n_translation_keys.id = tkl.translation_key_id')
        .joins('JOIN tr8n_translation_key_sources AS tks ON tr8n_translation_keys.id = tks.translation_key_id')
        .distinct.count('tr8n_translation_keys.id')

    self.translated_key_count = Tr8n::TranslationKey
        .where(['t.language_id = ? and tks.translation_source_id = ?', language_id, translation_source_id])
        .joins('JOIN tr8n_translations AS t ON tr8n_translation_keys.id = t.translation_key_id')
        .joins('JOIN tr8n_translation_key_sources AS tks ON tr8n_translation_keys.id = tks.translation_key_id')
        .distinct.count('tr8n_translation_keys.id')

    save

    # this needs to be done as an average of all languages for the source
    unless key_count == 0
      translation_source.completeness = 0
      translation_source.save
    end

    self
  end

  def not_translated_count
    return key_count unless translated_key_count
    key_count - translated_key_count
  end

  def pending_approval_count
    return translated_key_count unless locked_key_count
    translated_key_count - locked_key_count
  end

  def completeness
    return 0 if key_count.nil? or key_count == 0
    (locked_key_count * 100)/key_count
  end

  def translation_completeness
    return 0 if key_count.nil? or key_count == 0
    (translated_key_count * 100)/key_count
  end

  ###############################################################
  ## Offline Tasks
  ###############################################################
  def after_create
    Tr8n::OfflineTask.schedule(self.class.name, :update_metrics_offline, {
                               :translation_source_metric_id => self.id
    })
  end

  def self.update_metrics_offline(opts)
    Tr8n::TranslationSourceMetric.find_by_id(opts[:translation_source_metric_id]).update_metrics!
  end

end
