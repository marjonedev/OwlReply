class NewuserJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(user)
    user.send_informational_email
  end
end