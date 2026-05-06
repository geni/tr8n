
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
class Tr8n::TotalLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    self.user_count = Tr8n::LanguageUser.where(:language_id => language_id).count
    self.translator_count = Tr8n::LanguageUser.where(:language_id => language_id, :translator_id => nil).count
    self.translation_count = Tr8n::Translation.where(:language_id => language_id).count
    self.key_count = Tr8n::TranslationKey.count

    self.locked_key_count = Tr8n::TranslationKey
                              .where('tr8n_translation_key_locks.language_id' => language_id, 'tr8n_translation_key_locks.locked' => true)
                              .joins(:translation_key_locks)
                              .distinct
                              .count('tr8n_translation_key_locks.id')

    self.translated_key_count = Tr8n::TranslationKey
                                  .where('tr8n_translations.language_id' => language_id)
                                  .joins(:translations)
                                  .distinct.count('tr8n_translation_keys.id')
    save

    language.completeness = (locked_key_count * 100 / key_count)
    language.save

    self
  end

  def completeness
    language.completeness
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
                               :language_metric_id => self.id
    })
  end

  def self.update_metrics_offline(opts)
    Tr8n::LanguageMetric.find_by_id(opts[:language_metric_id]).update_metrics!
  end

end
