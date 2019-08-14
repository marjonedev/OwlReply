module SessionsHelper
  def logged_in?
    !current_user.nil?
  end

  def current_user_logged?
    if logged_in?
      current_user.id == params[:id]
    else
      false
    end

  end
end
