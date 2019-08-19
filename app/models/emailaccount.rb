class Emailaccount < ApplicationRecord
  belongs_to :user

  validates_presence_of :password, :if => :password_required?
  validates_presence_of :address
  validates_format_of :address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

end
