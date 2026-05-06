class Tr8n::Admin::ForumController < Tr8n::Admin::BaseController

  def index
    @topics = Tr8n::LanguageForumTopic.filter(:params => params, :filter => Tr8n::LanguageForumTopicFilter)
  end

  def messages
    @messages = Tr8n::LanguageForumMessage.filter(:params => params, :filter => Tr8n::LanguageForumMessageFilter)
  end

  def reports
    @reports = Tr8n::LanguageForumAbuseReport.filter(:params => params, :filter => Tr8n::LanguageForumAbuseReportFilter)
  end

  def delete_topic
    if request.delete?
      topic = Tr8n::LanguageForumTopic.find_by_id(params[:topic_id]) if params[:topic_id]
      topic.destroy if topic
    end

    redirect_to_source
  end

  def delete_message
    if request.delete?
      message = Tr8n::LanguageForumMessage.find_by_id(params[:msg_id]) if params[:msg_id]
      message.destroy if message
    end

    redirect_to_source
  end

  def delete_report
    if request.delete?
      report = Tr8n::LanguageForumAbuseReport.find_by_id(params[:report_id]) if params[:report_id]
      report.destroy if report
    end

    redirect_to_source
  end
end
