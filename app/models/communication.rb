class Communication < ApplicationRecord
  # Communication will be the class to hold marketing-related communications.
  # #1. New user signs up. Subject line: "Welcome to OwlReply"
  # #2. New user doesn't add any replies after 12 hours. Subject line: "Get your automated replies started"
  # #3. New user doesn't add their email account password after 24 hours. Subject line: "Get your automation connected."
  # #4. First time drafts are created for a new user.
  # #5. Daily report of automated emails created.
  # #6. Keyword suggestions after 7 days.
  # #7. Email sending best practices (48 hours after making account).
  # Etc.

  def self.send
    for communication in Communication.all
      for user in communication.get_users
        # Do not send if opted out.
        next unless Communicationsent.find_by(user_id: user.id, communication_id: self.id, opted_out: true).nil?

        # Use a job to send later.
        # Communicationjob.perform_later(communication, user)

        Communicationsent.create(user_id: user.id, communication_id: self.id, sent_at: Time.now)
      end
    end
  end

  def get_users # Finish later.
    return []
  end

  def send_to(user)

  end

end