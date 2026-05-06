
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
class Tr8n::MonthlyLanguageMetric < Tr8n::LanguageMetric

  def update_metrics!
    attribs = default_attributes

    attribs.each do |key, value|
      attribs[key] = Tr8n::DailyLanguageMetric
                      .where(['language_id = ? and metric_date >= ? and metric_date < ?', language_id, metric_date, metric_date + 1.month])
                      .sum(key)
    end

    update_attributes(attribs)
  end

end
