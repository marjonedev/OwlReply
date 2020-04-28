class NewuserfeedbackJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(user)
    UserMailer.with(user: self).feedback.deliver_later
  end
end
