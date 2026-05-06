class DummyController < ApplicationController
  helper Tr8n::HelperMethods

  def index
    # render app/views/dummy/index.html.erb
  end

  def switch_user
    user = User.where(id: params[:user_id]).first
    if user
      session[:user_id] = user.id
      redirect_to root_path, notice: "Switched to user: #{user.name}"
    else
      redirect_to root_path, alert: "User not found"
    end
  end
end
