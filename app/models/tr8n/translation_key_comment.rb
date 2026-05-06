
# == Schema Information
#
# Table name: tr8n_translation_key_comments
#
#  id                 :integer          not null, primary key
#  message            :text             not null
#  created_at         :datetime
#  updated_at         :datetime
#  language_id        :integer          not null
#  translation_key_id :integer          not null
#  translator_id      :bigint           not null
#
# Indexes
#
#  tr8n_tkey_msgs_lang_id          (language_id)
#  tr8n_tkey_msgs_lang_id_tkey_id  (language_id,translation_key_id)
#  tr8n_tkey_msgs_translator_id    (translator_id)
#
class Tr8n::TranslationKeyComment < ApplicationRecord

  belongs_to :language
  belongs_to :translator
  belongs_to :translation_key

  alias :key :translation_key

  def toHTML
    return "" unless message
    message.gsub("\n", "<br>")
  end

  def after_create
    Tr8n::Notification.distribute(self)
  end

  def can_be_deleted_by?(deleter)
    translator == deleter
  end
end
