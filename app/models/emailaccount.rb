class Emailaccount < ApplicationRecord
  belongs_to :user
  has_many :replies, :dependent => :destroy
  before_save :clear_errors

  attr_accessor :redirect_to

  validates_presence_of :address
  validates_format_of :address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  #validates_presence_of :password
  #validates_presence_of :encrypted_password
  #validates_presence_of :encryption_key
  validate :address_exist_validator, on: :create

  def subject_line_skip_words
    self.skip_words.split(",")
  end
  def subject_line_skip?(subject_line)
    for word in subject_line_skip_words
      return true if msg.subject.include?(word)
    end
    return false
  end

  # THIS NEEDS TO BECOME A DB FIELD and added to the form
  def skip_words
    ""
  end

  def clear_errors
    self.error = nil
  end

  def template_html
    self.template.to_s.gsub("\n","<br>\n")
    # In the future we may support BOLD, Italics, and what else? Should be very limited.
  end

  #def last_checked_at
  #  if error
  #    return "Last error: #{error}"
  #  end
  #  unless last_checked.nil?
  #    #return "Last checked at: #{Time.at(last_checked).utc.strftime("%m/%d/%Y %H:%M:%S")}"
  #  end
  #end
  # Probably should be in the view, otherwise maybe a helper if it will be used multiple places.
  #
  private

  def address_exist_validator
    accounts = Emailaccount.where(address: self.address)

    unless accounts.blank?
      errors.add(:address, "#{self.address} is already in use. Please use different email address.")
    end
  end

end
