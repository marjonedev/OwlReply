class NewuserJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(email_address)
    # CONNECT TO MAILCHIMP OR WHATEVER AUTOMATION
    # ADD THE EMAIL ADDRESS TO THE ONBOARDING LIST

    #if (object.respond_to?(:subscribe_if_needed))
    #  puts "Subscribing congoing #{object.class.to_s} #{object.id}."
    #  object.subscribe_if_needed
    #else
    #  #Raise an error.
    #end
  end
end