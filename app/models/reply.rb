class Reply < ApplicationRecord
  belongs_to :emailaccount

  before_validation :set_initial_content, on: [:create]

  def set_initial_content
    self.emailaccount_id = Emailaccount.current.id
  end
end
