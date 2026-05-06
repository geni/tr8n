
# == Schema Information
#
# Table name: tr8n_language_metrics
#
#  id                   :integer          not null, primary key
#  key_count            :integer          default(0)
#  locked_key_count     :integer          default(0)
#  metric_date          :date
#  translated_key_count :integer          default(0)
#  translation_count    :integer          default(0)
#  translator_count     :integer          default(0)
#  type                 :string
#  user_count           :integer          default(0)
#  created_at           :datetime
#  updated_at           :datetime
#  language_id          :integer          not null
#
# Indexes
#
#  index_tr8n_language_metrics_on_created_at   (created_at)
#  index_tr8n_language_metrics_on_language_id  (language_id)
#
class Tr8n::DailyLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    self.user_count = Tr8n::LanguageUser
                        .where(['language_id = ? and created_at >= ? and created_at < ?', language_id, metric_date, metric_date + 1.day])
                        .count

    self.translator_count = Tr8n::LanguageUser
                              .where(['language_id = ? and created_at >= ? and created_at < ? and translator_id is not null', language_id, metric_date, metric_date + 1.day])
                              .count

    self.translation_count = Tr8n::Translation
                              .where(['language_id = ? and created_at >= ? and created_at < ?', language_id, metric_date, metric_date + 1.day])
                              .count

    self.key_count = Tr8n::TranslationKey
                      .where(['created_at >= ? and created_at < ?', metric_date, metric_date + 1.day])
                      .count

    self.locked_key_count = Tr8n::TranslationKey
                              .where(['tr8n_translation_key_locks.language_id = ? and tr8n_translation_key_locks.locked = ? and tr8n_translation_key_locks.created_at >= ? and tr8n_translation_key_locks.created_at < ?', language_id, true, metric_date, metric_date + 1.day])
                              .joins('join tr8n_translation_key_locks on tr8n_translation_keys.id = tr8n_translation_key_locks.translation_key_id')
                              .distinct
                              .count('tr8n_translation_keys.id')

    self.translated_key_count = Tr8n::TranslationKey
                                  .where(['tr8n_translations.language_id = ? and tr8n_translations.created_at >= ? and tr8n_translations.created_at < ?', language_id, metric_date, metric_date + 1.day])
                                  .joins('join tr8n_translations on tr8n_translation_keys.id = tr8n_translations.translation_key_id')
                                  .distinct
                                  .count('tr8n_translation_keys.id')

    save
  end

end
