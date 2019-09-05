class ApplicationController < ActionController::Base

  helper_method :current_user

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def logged_in?
    !current_user.nil?
  end

  def logged_in_user
    if !logged_in?
      redirect_to login_url
    end
  end

end
