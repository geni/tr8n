class ApplicationController < ActionController::Base

  helper_method :current_locale
  def current_locale
    if params[:locale]
      session[:locale] = params[:locale] if Tr8n::Language.for(params[:locale])
      save_locale = request.post?
    elsif !current_user.guest? and current_user.locale != nil
      session[:locale] = current_user.locale
    elsif (session[:locale] == nil) || (!current_user.guest? and current_user.locale.nil?)
      session[:locale] = tr8n_user_preferred_locale
      save_locale = (session[:locale] != Tr8n::Config.default_locale)
    end

    if save_locale and !current_user.guest?
      current_user.update_attributes!(:locale => session[:locale])
    end

    session[:locale]
  end

  helper_method :current_user
  def current_user
    @current_user ||= User.find_by_id(session[:user_id].to_i) || User.new(:id => -1, :name => 'Guest', :guest => true).freeze
  end

end
