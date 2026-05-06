
# == Schema Information
#
# Table name: tr8n_language_forum_abuse_reports
#
#  id                        :integer          not null, primary key
#  reason                    :string
#  created_at                :datetime
#  updated_at                :datetime
#  language_forum_message_id :integer          not null
#  language_id               :integer          not null
#  translator_id             :integer          not null
#
# Indexes
#
#  tr8n_forum_reports_lang_id                (language_id)
#  tr8n_forum_reports_lang_id_translator_id  (language_id,translator_id)
#  tr8n_forum_reports_message_id             (language_forum_message_id)
#
class Tr8n::LanguageForumAbuseReport < ApplicationRecord

  belongs_to :language
  belongs_to :translator
  belongs_to :language_forum_message

  alias :message :language_forum_message

end
