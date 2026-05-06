
# == Schema Information
#
# Table name: tr8n_language_forum_messages
#
#  id                      :integer          not null, primary key
#  message                 :text             not null
#  created_at              :datetime
#  updated_at              :datetime
#  language_forum_topic_id :integer          not null
#  language_id             :integer          not null
#  translator_id           :integer          not null
#
# Indexes
#
#  tr8n_forum_msgs_lang_id           (language_id)
#  tr8n_forum_msgs_lang_id_topic_id  (language_id,language_forum_topic_id)
#  tr8n_forums_msgs_translator_id    (translator_id)
#
class Tr8n::LanguageForumMessage < ApplicationRecord

  belongs_to :language
  belongs_to :translator
  belongs_to :language_forum_topic

  has_many :language_forum_abuse_reports, :dependent => :destroy

  alias :topic :language_forum_topic

  def submit_abuse_report(reporter)
    report = Tr8n::LanguageForumAbuseReport
              .where(["language_forum_message_id = ? and translator_id = ?", self.id, reporter.id])
              .first
    report ||= Tr8n::LanguageForumAbuseReport.create(:language_forum_message => self, :translator => reporter, :language => language)
    translator.update_attributes(:reported => true)
    report
  end

  def toHTML
    return "" unless message
    ERB::Util.html_escape(message).gsub("\n", "<br>")
  end

  def after_create
    Tr8n::Notification.distribute(self)
  end

end
