module SubscriptionCharger
  class Charge
    def self.start

    end
    def self.check_user
      users = User.where("next_subscription_charge_on <> NULL").where("subscription_id > 1")

      for user in users
        if user.next_subscription_charge_on = Time.zone.now.to_date
          self.charge_user(user)
        end
      end
    end
    def self.charge_user(user)
      user.invoices.create(subscription_id: user.subscription_id)
      user.set_next_subscription_date!
    end
  end
end