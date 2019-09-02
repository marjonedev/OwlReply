class Paymentmethod < ApplicationRecord
  belongs_to :user

  after_save :set_default

  def set_default
    if self.default
      Paymentmethod.where(user_id: self.user_id).where.not(id: id).update_all(default: false)
    end
  end
end
