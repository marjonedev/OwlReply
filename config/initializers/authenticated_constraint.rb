class AuthenticatedConstraint
  def initialize
  end

  def matches?(request)
    !current_user.nil?
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end
end