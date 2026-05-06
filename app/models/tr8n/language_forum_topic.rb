
# == Schema Information
#
# Table name: tr8n_language_forum_topics
#
#  id            :integer          not null, primary key
#  topic         :text             not null
#  created_at    :datetime
#  updated_at    :datetime
#  language_id   :integer
#  translator_id :integer          not null
#
# Indexes
#
#  tr8n_forum_topics_lang_id        (language_id)
#  tr8n_forum_topics_translator_id  (translator_id)
#
class Tr8n::LanguageForumTopic < ApplicationRecord

  belongs_to :language
  belongs_to :translator

  has_many :language_forum_messages, :dependent => :destroy

  alias :messages :language_forum_messages

  def post_count
    @post_count ||= Tr8n::LanguageForumMessage.where(:language_forum_topic_id => self.id).count
  end

  def last_post
    @last_post ||= Tr8n::LanguageForumMessage.where(:language_forum_topic_id => self.id).order("created_at desc").first
  end
end
