class Emailaccount < ApplicationRecord
  belongs_to :user
  has_many :replies

  validates_presence_of :address
  validates_format_of :address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  #validates_presence_of :password
  #validates_presence_of :encrypted_password
  #validates_presence_of :encryption_key

  def subject_line_skip_words
    self.skip_words.split(",")
  end
  def subject_line_skip?(subject_line)
    for word in subject_line_skip_words
      return true if msg.subject.include?(word)
    end
    return false
  end

  def template_html
    self.body.gsub("\n","<br>\n")
    # In the future we may support BOLD, Italics, and what else? Should be very limited.
  end

end
