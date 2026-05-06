
class Tr8n::LanguageForumMessageFilter < Tr8n::BaseFilter

  def inner_joins
    [["Tr8n::Language", :language_id], ["Tr8n::LanguageForumTopic", :language_forum_topic_id], ["Tr8n::Translator", :translator_id]]
  end
  
  def default_filter_if_empty
    "created_today"
  end
  
end
