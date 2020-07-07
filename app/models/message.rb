class Message < ApplicationRecord
  belongs_to :emailaccount

  def self.clear_messages(emailaccount, days = 0)
    emailaccount.messages.where('created_at < ?', days.days.ago).destroy_all
  end
end
