class User < ApplicationRecord
  has_one :subscription
  has_many :emailaccounts
  has_many :replies, through: :emailaccounts
  has_many :transactions, through: :invoices
  has_many :invoices
  has_many :paymentmethods

  attr_accessor :password

  validates_presence_of :username
  validates_confirmation_of :password
  validates_presence_of :password, :if => :password_required?
  validates_length_of :password, :within => 8..40, :if => :password_required?
  validates_length_of :username, :within => 5..40
  validates_uniqueness_of :username, :case_sensitive => false
  validates_presence_of :email_address
  validates_format_of :email_address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_format_of :username, :with => /\A[a-z][a-z0-9\_]*?\Z/, :message => "must start with a letter and include only letters, numbers, and underscore."

  before_save :encrypt_password
  before_validation :set_initial_content, on: [:create]
  before_validation :lowercase_username
  after_create :create_initial_emailaccount

  def set_initial_content
    self.password = self.email_address
    self.username = self.email_address.gsub("@","_").gsub(".","_")
    # set default subscription_id
    s = Subscription.find_by(name: "Entrepreneur").id
    self.subscription_id = s
    #CongoingsubscribeJob.perform_later(self.email_address)
  end

  def create_initial_emailaccount
    Emailaccount.create(user_id: self.id, address: self.email_address)
  end

  def no_paymentmethods?
    self.paymentmethods.first.nil?
  end

  def current_subscription_id
    return nil if self.invoices.empty?
    self.invoices.first.subscription_id
  end

  def set_subscription!(subscription)
    self.update_attribute(:subscription_id,subscription.id)
    self.generate_first_invoice! if current_subscription_id.nil?
    self.generate_first_invoice! unless current_subscription_id.nil?
  end

  def generate_first_invoice!
    self.invoices.create(subscription_id: self.subscription_id) if current_subscription_id.nil? # Amount, date, and collecting payment too, will be done by the invoice object 'on_create'.
    self.update_attribute(:subscription_start_date,DateTime.now)
  end

  def generate_upgrade_invoice!
    # If old price is less than the new price.
    previous_subscription = Subscription.find(current_subscription_id)
    if previous_subscription.price < self.subscription.price
      self.invoices.create(subscription_id: self.subscription_id, previous_price: previous_subscription.price)
    end
  end

  def set_next_subscription_date!
    self.update_attribute(:next_subscription_charge_on, 1.month.from_now)
  end

  def lowercase_username
    self.username.downcase!
  end

  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def self.encrypt(password,salt)
    Digest::SHA512.hexdigest("--#{salt}---#{password}--")
  end

  def self.authenticate(username, password)
    user = find_by(username: username)
    if user && user.encrypted_password == User.encrypt(password, user.salt)
      user
    else
      nil
    end
  end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}---#{username}--") if new_record?
      self.encrypted_password = encrypt(password)
    end

    def password_required?
      encrypted_password.blank? || !password.blank?
    end
end
