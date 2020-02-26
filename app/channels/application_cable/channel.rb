module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def current_usr
      #@current_user ||= login_from_session || :false
    end
    def login_from_session
      #self.current_user = User.find_by_id(request.session[:user_id]) if request.session[:user_id]
    end

  end
end
