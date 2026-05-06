
class Tr8n::LanguageForumAbuseReportFilter < Tr8n::BaseFilter

  def inner_joins
    [["Tr8n::Language", :language_id], ["Tr8n::LanguageForumMessage", :language_forum_message_id], ["Tr8n::Translator", :translator_id]]
  end
  
end
