
# == Schema Information
#
# Table name: tr8n_translator_reports
#
#  id            :integer          not null, primary key
#  comment       :text
#  object_type   :string
#  reason        :string
#  state         :string
#  created_at    :datetime
#  updated_at    :datetime
#  object_id     :integer
#  translator_id :bigint
#
# Indexes
#
#  index_tr8n_translator_reports_on_translator_id  (translator_id)
#
class Tr8n::TranslatorReport < ApplicationRecord

  belongs_to :translator
  belongs_to :object, :polymorphic => true

  def self.find_or_create(translator, object)
    report_for(translator, object) || create(:translator => translator, :object => object)
  end

  def self.report_for(translator, object)
    find(:first, :conditions => ["translator_id = ? and object_type = ? and object_id = ?", translator.id, object.class.name, object.id])
  end

  def self.title_for(object)
    object.class.name.underscore.split('_').collect{|item| item.capitalize}.join(' ')
  end

  def self.default_reasons_for(object)
    if object.is_a?(Tr8n::TranslationKey)
      return ['Bad Grammar', 'Bad Tokens', 'Premature Lock', 'Other:']
    end

    if object.is_a?(Tr8n::Translation)
      return ['Inappropriate Language', 'Bad Tokens', 'Spam', 'Vandalism', 'Other:']
    end

    if object.is_a?(Tr8n::Translator)
      return ['Spammer', 'Vandalist', 'Bully', 'Other:']
    end

    if object.is_a?(Tr8n::LanguageForumMessage)
      return ['Inappropriate Language', 'Bad Tokens', 'Spam', 'Vandalism', 'Other:']
    end

    if object.is_a?(Tr8n::LanguageForumTopic)
      return ['Inappropriate Language', 'Bad Tokens', 'Spam', 'Vandalism', 'Other:']
    end

    if object.is_a?(Tr8n::TranslationKeyComment)
      return ['Inappropriate Language', 'Spam', 'Vandalism', 'Other:']
    end

    ['Inappropriate Language']
  end

  def self.submit(translator, object, reason, comment)
    report = find_or_create(translator, object)
    report.update_attributes(:reason => reason, :comment => comment)

    if object.is_a?(Tr8n::Translation)
      object.vote!(translator, -100)
      submit(translator, object.translator, "bad translation #{object.id}", comment)
    elsif object.is_a?(Tr8n::LanguageForumMessage)
      submit(translator, object.translator, "bad message #{object.id}", comment)
    end
  end

end
