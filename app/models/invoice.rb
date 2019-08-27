class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :subscription
  has_many :transactions
  before_create :set_details
  after_create :charge_card
  attr_accessor :previous_price

  def set_details
    self.amount = self.subscription.price
    self.date = Date.today
    self.amount = self.amount - self.previous_price unless (self.previous_price.nil? || (self.previous_price > self.amount))
  end

  def charge_card
    paymentmethod = self.user.paymentmethods.order('current DESC').first
    result = paymentmethod.charge(self.amount)
    if (result)
      self.paid_amount = self.amount
      self.time_paid = Time.now
      #
      # Send an email receipt.
    else

      # Send an email "Please update your billing information."
    end
  end

end
