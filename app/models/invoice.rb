class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :subscription
  has_many :transactions
  before_create :set_details
  # after_create :charge_card #todo: temporary commented. charge card after create
  after_create :set_next_subscription_date
  attr_accessor :previous_price

  def set_details
    self.amount = self.subscription.price
    self.date = Date.today
    self.amount = self.amount - self.previous_price unless (self.previous_price.nil? || (self.previous_price > self.amount))
  end

  def charge_card
    paymentmethod = self.user.paymentmethods.find_by(default: true)
    result = paymentmethod.charge!(self.amount)
    if (result)
      #self.paid_amount = self.amount
      #self.date_paid = DateTime.now
      self.update_attributes(paid_amount: self.amount, date_paid: DateTime.now)

      #
      # Send an email receipt.
    else

      # Send an email "Please update your billing information."
    end
  end

  def set_next_subscription_date
    self.user.set_next_subscription_date!
  end

end
