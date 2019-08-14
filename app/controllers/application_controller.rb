class ApplicationController < ActionController::Base

  helper_method :current_user

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end

  def render_not_found
    render :file => "#{Rails.root}/public/404.html",  :status => 404
  end

end
