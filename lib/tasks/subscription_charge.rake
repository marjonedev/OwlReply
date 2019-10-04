namespace :subscription_charge do
  desc "This will iterate everyday to charge user on next subscription"
  task do: :environment do
    SubscriptionCharger::Charge.start
  end

end
