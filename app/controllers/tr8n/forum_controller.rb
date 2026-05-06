module Tr8n
  class ForumController < ApplicationController
    set_tr8n_feature  :forum

    before_filter :validate_current_translator

    def index
      @topics = Tr8n::LanguageForumTopic
                  .where(['language_id = ?', tr8n_current_language.id])
                  .order('created_at DESC')
                  .paginate(:page => page, :per_page => per_page)
    end

    def topic
      if request.post?
        if params[:topic_id]
          topic = Tr8n::LanguageForumTopic.find_by_id(params[:topic_id])
        else
          topic = Tr8n::LanguageForumTopic.create(:language_id => tr8n_current_language.id, :translator => tr8n_current_translator, :topic => params[:topic])
        end

        Tr8n::LanguageForumMessage.create(:language_forum_topic => topic, :language_id => tr8n_current_language.id, :message => params[:message], :translator => tr8n_current_translator)
        return redirect_to(:action => :topic, :topic_id => topic.id, :last_page => true)
      end

      unless params[:mode] == "create"
        @topic = Tr8n::LanguageForumTopic.find_by_id(params[:topic_id])
        if params[:last_page]
          params[:page] = (@topic.post_count / per_page.to_i)
          params[:page] += 1 unless (@topic.post_count % per_page.to_i == 0)
        end

        @messages = Tr8n::LanguageForumMessage.paginate(:all, :conditions => ["language_forum_topic_id = ?", @topic.id], :page => page, :per_page => per_page, :order => "created_at asc")
      end
    end

    def delete_topic
      if request.post?
        topic = Tr8n::LanguageForumTopic.find_by_id(params[:topic_id])

        if topic.translator != tr8n_current_translator
          trfe("You cannot delete topics you didn't create.")
          return redirect_to(:action => :index)
        end

        topic.destroy if topic
        trfn("The topic {topic} has been removed", 'Tr8n Forum', :topic => "\"#{topic.topic.escape_html}\"")
      end

      redirect_to(:action => :index)
    end

    def delete_message
      if request.post?
        message = Tr8n::LanguageForumMessage.find_by_id(params[:message_id])

        unless message
          trfe("This message does not exist")
          return redirect_to(:action => :index)
        end

        if message.translator != tr8n_current_translator
          trfe("You cannot delete messages you didn't post.")
          return redirect_to(:action => :topic, :topic_id => message.language_forum_topic.id)
        end

        message.destroy
        trfn("The message has been removed")
      end

      redirect_to(:action => :topic, :topic_id => message.language_forum_topic.id)
    end

    def report_message
      if request.post?
        message = Tr8n::LanguageForumMessage.find_by_id(params[:message_id])

        unless message
          trfe("This message does not exist")
          return redirect_to(:action => :index)
        end

        message.submit_abuse_report(tr8n_current_translator)

        trfn("The message has been reported")
      end

      redirect_to(:action => :topic, :topic_id => message.language_forum_topic.id)
    end

  end # class ForumController
end # module Tr8n
