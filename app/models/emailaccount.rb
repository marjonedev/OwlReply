class Emailaccount < ApplicationRecord
  belongs_to :user
  has_many :replies

  validates_presence_of :address
  validates_format_of :address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  #validates_presence_of :password
  #validates_presence_of :encrypted_password
  #validates_presence_of :encryption_key

  before_validation :set_initial_content, on: [:create]

  def set_initial_content
    self.user_id = User.current.id
  end

  def self.current
    Thread.current[:emailaccount]
  end

  def self.current=(emailaccount)
    Thread.current[:emailaccount] = emailaccount
  end

end
