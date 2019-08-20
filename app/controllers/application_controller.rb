class ApplicationController < ActionController::Base

  helper_method :current_user
  before_action :set_current_user

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end

  def set_current_user
    User.current = current_user
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

end
