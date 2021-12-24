class Emailaccount < ApplicationRecord
  belongs_to :user
  has_many :replies, :dependent => :destroy
  has_many :messages, :dependent => :destroy
  before_save :clear_errors

  validates_presence_of :address
  validates_format_of :address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  #validates_presence_of :password
  #validates_presence_of :encrypted_password
  #validates_presence_of :encryption_key
  validate :address_exist_validator, on: :create
  after_commit :create_emailaccount_job, on: :create

  def create_emailaccount_job
    NewemailaccountJob.perform_later(self)
  end

  def subject_line_skip_words
    self.skip_words.split(",")
  end
  def subject_line_skip?(subject_line)
    for word in subject_line_skip_words
      return true if msg.subject.include?(word)
    end
    return false
  end

  def template_top
    self.template.to_s.split("%%reply%%").first
  end
  def template_bottom
    self.template.to_s.split("%%reply%%").last
  end

  def template_blank?
    (self.template.nil? || self.template.to_s.strip == "")
  end

  # THIS NEEDS TO BECOME A DB FIELD and added to the form
  def skip_words
    ""
  end

  def get_email_messages(limit: 500, unread: false)
    @gmail_api ||= GoogleConnector::GmailApi.new self
    messages = @gmail_api.get_messages(limit: limit)
    # Why don't we return the original? Is it about :symbolifying the things? Cause that can be done.
    messages.map do |msg|
      date = DateTime.parse(msg['date'])
      formatted_date = date.strftime('%a, %b %d, %Y at %I:%M %p')
      subject = msg['subject']
      from = msg['from']
      thebody = msg['body_text'].to_s.gsub("\r\n", " ")
      thebody = thebody.truncate(80, separator: " ")

      {date: formatted_date, subject:subject, body: msg['body'], body_text: thebody, from: from}
    end
  end

  def my_gmail_api
    @gmail_api ||= GoogleConnector::GmailApi.new self
  end

  def crunch_initial_words
    #return if self.crunched
    messages = my_gmail_api.get_messages(limit: 30, unread: false)
    for msg in messages
      thebody = msg['body'].to_s
      thebody_downcase = thebody.downcase
      Wordcount.count(self,thebody_downcase)
    end
  end

  def set_debug_message(message)
    self.update_attribute(:debugmessage,message)
    EmailaccountChannel.broadcast_to(self, {debug: message})
  end

  def update_last_checked(time)
    self.update_column(:last_checked,time)
    data = {last_checked: "Last checked: Just now."}
    EmailaccountChannel.broadcast_to(self, data)
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
      errors.add(:address, "#{self.address} is already in use. Please use a different email address.")
    end
  end

end
