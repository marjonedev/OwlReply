module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def current_usr
      @current_user ||= (login_from_session || login_from_cookie || :false)
    end
    def login_from_session
      self.current_user = User.find_by_id(request.session[:user_id]) if request.session[:user_id]
    end
    def reset_channel
      @current_user = nil
    end
    def login_from_cookie
      return nil
      user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
        self.current_user = user
      end
    end
  end
end
