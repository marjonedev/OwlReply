class Subscription < ApplicationRecord
  has_many :invoices

  validates :name, :price, :frequency, :presence => true

  def self.update_subscriptions_today
    users = User.where("next_subscription_charge_on IS NOT NULL").where("subscription_id > 1")
    for user in users
      if user.next_subscription_charge_on.to_date == Time.zone.now.to_date
        user.invoices.create(subscription_id: user.subscription_id)
        user.set_next_subscription_date!
      end
    end
  end

end