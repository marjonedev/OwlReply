class NewemailaccountJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(emailaccount)
    emailaccount.crunch_initial_words
  end
end
