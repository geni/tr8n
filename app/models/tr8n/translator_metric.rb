
# == Schema Information
#
# Table name: tr8n_translator_metrics
#
#  id                    :integer          not null, primary key
#  accepted_translations :integer          default(0)
#  negative_votes        :integer          default(0)
#  positive_votes        :integer          default(0)
#  rejected_translations :integer          default(0)
#  total_translations    :integer          default(0)
#  total_votes           :integer          default(0)
#  created_at            :datetime
#  updated_at            :datetime
#  language_id           :bigint
#  translator_id         :integer          not null
#
# Indexes
#
#  index_tr8n_translator_metrics_on_created_at                     (created_at)
#  index_tr8n_translator_metrics_on_translator_id                  (translator_id)
#  tr8n_translator_metrics_translator_id_and_language_id_uniq      (translator_id,COALESCE(language_id,-1)) UNIQUE
#
class Tr8n::TranslatorMetric < ApplicationRecord

  belongs_to :translator
  belongs_to :language

  def self.find_or_create(translator, language)
    metric_for(translator, language) || create_metric(translator, language)
  end

  def self.create_metric(translator, language)
    # The NOT EXISTS guard below must match on translator_id, not id (this table's own
    # primary key), or it fails to prevent concurrent callers from both inserting a
    # duplicate row for the same translator (most visibly the language_id IS NULL
    # "totals" row, since unique indexes treat NULL as distinct from NULL and so don't
    # block it at the DB level either).
    language_match = language ? "language_id = #{language.id}" : 'language_id IS NULL'

    connection.update %{
      INSERT INTO #{quoted_table_name}
      (translator_id, language_id, total_translations, total_votes, positive_votes, negative_votes, created_at, updated_at)
      SELECT #{translator.id}, #{language ? language.id : 'NULL'}, 0, 0, 0, 0,
             #{connection.quote(Time.now.utc)}, #{connection.quote(Time.now.utc)}
      WHERE NOT EXISTS (
        SELECT id FROM #{quoted_table_name}
        WHERE translator_id = #{translator.id} and #{language_match}
      )
    }

    metric_for(translator, language)
  end

  def self.metric_for(translator, language)
    where(:translator_id => translator.id, :language_id => language && language.id).first
  end

  # updated when an action is done by the translator
  def update_metrics!
    if language
      self.total_translations = Tr8n::Translation
                                  .where(:translator_id => translator.id, :language_id => language.id)
                                  .count

      self.total_votes = Tr8n::TranslationVote
                          .where(:tr8n_translation_votes => {:translator_id => translator.id}, :tr8n_translations => {:language_id => language.id})
                          .joins(:translation)
                          .count

      self.positive_votes = Tr8n::TranslationVote
                              .where(:tr8n_translation_votes => {:translator_id => translator.id, :vote => 1}, :tr8n_translations => {:language_id => language.id})
                              .joins(:translation)
                              .count

      self.negative_votes = self.total_votes - self.positive_votes
    else
      self.total_translations = Tr8n::Translation.where(:translator_id => translator.id).count
      self.total_votes = Tr8n::TranslationVote.where(:translator_id => translator.id).count
      self.positive_votes = Tr8n::TranslationVote.where(:translator_id => translator.id, :vote => 1).count
      self.negative_votes = self.total_votes - self.positive_votes
    end

    save
  end

  # updated when an action is done to the translator's translations
  def update_rank!
    if language
      self.accepted_translations = Tr8n::Translation
                                    .where(:translator_id => translator.id, :language_id => language.id, :rank => Tr8n::Config.translation_threshold..)
                                    .count

      self.rejected_translations = Tr8n::Translation
                                    .where(:translator_id => translator.id, :language_id => language.id, :rank => 0..)
                                    .count
    else
      self.accepted_translations = Tr8n::Translation
                                    .where(:translator_id => translator.id, :rank => Tr8n::Config.translation_threshold..)
                                    .count
      self.rejected_translations = Tr8n::Translation
                                    .where(:translator_id => translator.id, :rank => 0..)
                                    .count
    end

    save
  end

  def rank
    return 0 unless total_translations and accepted_translations

    total_translations == 0 ? 0 : (accepted_translations * 100.0/total_translations)
  end

  def pending_vote_translations
    return total_translations unless accepted_translations and rejected_translations
    total_translations - accepted_translations - rejected_translations
  end
end
