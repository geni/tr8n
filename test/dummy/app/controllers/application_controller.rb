class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_locale
  def current_locale
    session[:locale] || params[:locale] || Tr8n::Config.default_locale
  end

  helper_method :current_user
  def current_user
    @current_user ||= User.find_by_id(session[:user_id].to_i) || User.new(:id => -1, :name => 'Guest', :guest => true).freeze
  end

end
