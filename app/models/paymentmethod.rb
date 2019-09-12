class Paymentmethod < ApplicationRecord
  belongs_to :user
  after_save :set_default
  after_create :set_customer_id
  before_create :set_initial_default
  after_destroy :set_destroy_default

  def charge!(amount)
    begin
      Stripe.api_key = Rails.application.credentials.stripe_api_key
      # Note: If the token is cus_XXXX then that's a customer_id.
      # If the token is something else, then it's a source_id (basically a card id but technically could be a bank account or bitcoins or something in the FUTURE.)
      charge = Stripe::Charge.create(
          amount: amount, # amount in cents
          currency: "usd",
          customer: self.customer_id,
          description: "Convention registration."
      )
      return charge
    rescue Stripe::CardError => e
      return false
    end
  end

  def set_customer_id
    customer = Stripe::Customer.create(
        description: "User ##{self.user.id}",
        source: token,
        email: "#{self.user.email_address}"
    )
    self.update_column(:customer_id,customer.id)
  end

  def set_default
    if self.default
      self.user.paymentmethods.where.not(id: self.id).update_all(default: false)
      #Paymentmethod.where(user_id: self.user_id).where.not(id: self.id).update_all(default: false)
    end
  end

  def set_initial_default
    if Paymentmethod.where(user_id: self.user_id).first.nil?
      self.default = true
    end
  end

  def set_destroy_default
    if self.default
      self.user.paymentmethods.first.update_attribute(:default,true)
      #Paymentmethod.where(user_id: self.user_id).first.default = true
    end
  end
end
