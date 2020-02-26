class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    stream_from "user_#{current_user.id}"
    send_data({message:"Connected, #{current_user.login}."})
  end
  def unsubscribed
  end
  def receive(data)
    if data['something']
      # Do Thing.
    end
  end

  def send_message_to_user(message)
    data = {message: message}
    send_data(data) #UserChannel.broadcast_to(current_user, data)
  end

  # Only used on instances. In other classes, we will have to call UserChannel.broadcast_to(user, data)
  def send_data(data)
    UserChannel.broadcast_to(current_user, data)
  end
end