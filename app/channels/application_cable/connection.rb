module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_admin
    def connect
      self.current_user = find_verified_user
      self.current_admin = find_verified_user
    end
    private
    def find_verified_user
      if verified_user = User.find_by_id(request.session[:user_id])
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
