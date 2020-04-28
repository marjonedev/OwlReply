class NewuserguideJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(user)
    UserMailer.with(user: self).informational_email.deliver_later
  end
end
