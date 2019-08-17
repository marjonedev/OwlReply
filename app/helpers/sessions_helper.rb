module SessionsHelper
  def logged_in?
    !current_user.nil?
  end

  def logged_in_user
    if !logged_in?
      redirect_to login_url
    end
  end

end
