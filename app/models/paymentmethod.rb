class Paymentmethod < ApplicationRecord
  belongs_to :user

  after_save :set_default
  before_save :set_initial_default

  def set_default
    if self.default
      Paymentmethod.where(user_id: self.user_id).where.not(id: id).update_all(default: false)
    end
  end

  def set_initial_default
    if Paymentmethod.where(user_id: self.user_id).first.nil?
      self.default = true
    end
  end
end
