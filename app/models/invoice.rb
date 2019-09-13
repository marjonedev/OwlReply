class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :subscription
  has_many :transactions
  before_create :set_details
  after_create :charge_card #todo: charge card after create
  after_create :set_next_subscription_date, :set_invoice_number
  attr_accessor :previous_price

  def set_details
    self.amount = self.subscription.price
    self.date = Date.today
    self.amount = self.amount - self.previous_price unless (self.previous_price.nil? || (self.previous_price > self.amount))
  end

  def set_invoice_number
    number = "INV/#{Date.current.year}/%.4i" % self.id
    self.update_attribute(:number, number)
  end

  def charge_card
    paymentmethod = self.user.paymentmethods.find_by(default: true)
    result = paymentmethod.charge!(self.amount.to_i*100)
    if (result)
      #self.amount_paid = self.amount
      #self.date_paid = DateTime.now
      self.update_attributes(amount_paid: self.amount, date_paid: DateTime.now)

      #
      # Send an email receipt.
    else

      # Send an email "Please update your billing information."
    end
  end

  def paid?
    self.amount_paid == self.amount
  end

  def set_next_subscription_date
    self.user.set_next_subscription_date!
  end

end
