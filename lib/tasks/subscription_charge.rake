namespace :subscription_charge do
  desc "This will iterate everyday to charge user on next subscription"
  task do: :environment do
    Subscription.update_subscriptions_today
  end

end
