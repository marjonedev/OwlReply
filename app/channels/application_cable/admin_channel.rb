class AdminChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_admin
    stream_from "admin_#{current_user.id}_channel"
  end
  def unsubscribed
  end
  def receive(data)
    if data['something']
      # Do Thing.
    end
  end
end