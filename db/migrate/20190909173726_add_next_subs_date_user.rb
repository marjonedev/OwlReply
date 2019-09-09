class AddNextSubsDateUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :next_subscription_charge_on, :date
  end
end
