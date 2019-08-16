class User < ApplicationRecord
  has_many :emailaccount

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
  before_validation :lowercase_username

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
