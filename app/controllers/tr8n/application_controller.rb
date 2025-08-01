module Tr8n
  class ApplicationController < ::ApplicationController
    include Tr8n::ApplicationHelper

    append_before_action :init_tr8n

    def init_tr8n
      return unless Tr8n::Config.enabled?

      tr8n_current_locale = nil

      begin
        tr8n_current_locale = eval(Tr8n::Config.current_locale_method)
      rescue Exception => ex
        # fallback to the default session based locale implementation
        # choose the first language from the accepted languages header
        session[:locale] = tr8n_user_preffered_locale unless session[:locale]
        session[:locale] = params[:locale] if params[:locale]
        tr8n_current_locale = session[:locale]
      end

      tr8n_current_user = nil
      if Tr8n::Config.site_user_info_enabled?
        begin
          tr8n_current_user = eval(Tr8n::Config.current_user_method)
          # TODO: verify what this was needed for
          # tr8n_current_user = nil if tr8n_current_user.class.name != Tr8n::Config.user_class_name
        rescue Exception => ex
          raise Tr8n::Exception.new("Tr8n cannot be initialized because #{Tr8n::Config.current_user_method} failed with: #{ex.message}")
        end
      else
        tr8n_current_user = Tr8n::Translator.find_by_id(session[:tr8n_translator_id]) if session[:tr8n_translator_id]
        tr8n_current_user = Tr8n::Translator.new unless tr8n_current_user
      end

      # initialize request thread variables
      Tr8n::Config.init(tr8n_current_locale, tr8n_current_user, tr8n_source, tr8n_component)

      # for logged out users, fallback onto tr8n_access_key
      if Tr8n::Config.current_user_is_guest?
        tr8n_access_key = params[:tr8n_access_key] || session[:tr8n_access_key]
        unless tr8n_access_key.blank?
          Tr8n::Config.set_translator(Tr8n::Translator.find_by_access_key(tr8n_access_key))
        end
      end

      # invalidate source for the current page
      Tr8n::Cache.invalidate_source(Tr8n::Config.current_source)

      # track user's last ip address
      if Tr8n::Config.enable_country_tracking? and Tr8n::Config.current_user_is_translator?
        Tr8n::Config.current_translator.update_last_ip(request.remote_ip)
      end

      # register component and verify that the current user is authorized to view it
      unless Tr8n::Config.current_user_is_authorized_to_view_component?
        trfe("You are not authorized to view this component")
        return redirect_to(Tr8n::Config.default_url)
      end

      unless Tr8n::Config.current_user_is_authorized_to_view_language?
        Tr8n::Config.set_language(Tr8n::Config.default_language)
      end
    end # def init_tr8n

    ######################################################################
    # Author: Iain Hecker
    # reference: http://github.com/iain/http_accept_language
    ######################################################################
    def tr8n_browser_accepted_locales
      @accepted_languages ||= request.env['HTTP_ACCEPT_LANGUAGE'].split(/\s*,\s*/).collect do |l|
        l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
        l.split(';q=')
      end.sort do |x,y|
        raise Tr8n::Exception.new("Not correctly formatted") unless x.first =~ /^[a-z\-]+$/i
        y.last.to_f <=> x.last.to_f
      end.collect do |l|
        l.first.downcase.gsub(/-[a-z]+$/i) { |x| x.upcase }
      end
    rescue
      []
    end # def tr8n_browser_accepted_locales

  end # class ApplicationController
end # module Tr8n
