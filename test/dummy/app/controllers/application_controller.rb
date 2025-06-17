class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def current_locale
    params[:locale] || Tr8n::Config.default_locale
  end

  def current_user
    session[:user_id] ? User.find(session[:user_id])  : nil
  end

end
