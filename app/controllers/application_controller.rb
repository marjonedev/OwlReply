class ApplicationController < ActionController::Base

  helper_method :current_user
  before_action :set_referer_cookies

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

  def require_login
    if !logged_in?
      redirect_to "#{login_url}?redirect_to=#{ERB::Util.url_encode(request.fullpath)}"
    end
  end

  def require_admin
    if !logged_in?
      redirect_to login_url
    end

    if current_user and !current_user.admin
      redirect_to login_url
    end
  end

  def set_referer_cookies
    cookies[:referer] = request.referer
  end

end
