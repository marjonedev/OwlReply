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
    self.payment_currency = "USD"
  end

  def set_invoice_number
    number = "#{Date.current.year}-%.6i" % self.id
    self.update_attribute(:number, number)
  end

  def charge_card
    paymentmethod = self.user.paymentmethods.find_by(default: true)
    result = paymentmethod.charge!(self.amount)
    user = self.user
    invoice = Invoice.find(self.id)
    if (result)
      #self.amount_paid = self.amount
      #self.date_paid = DateTime.now
      self.update_attributes(amount_paid: self.amount, date_paid: DateTime.now)
      #
      # Send an email receipt.
      user = self.user
      invoice = Invoice.find(self.id)
      InvoiceMailer.with(user: user, invoice: invoice).invoice_created.deliver_now
    else

      InvoiceMailer.with(user: user, invoice: invoice).invoice_failed.deliver_now

      return

      # Send an email "Please update your billing information."
    end
  end

  def paid?
    self.amount_paid == self.amount
  end

  def set_next_subscription_date
    self.user.set_next_subscription_date!
  end

  def amount_paid_to_string
    tail = "%.2d" % (self.amount_paid%100)
    "$#{self.amount_paid/100}.#{tail}"
  end

  def amount_to_string
    tail = "%.2d" % (self.amount%100)
    "$#{self.amount/100}.#{tail}"
  end

end
