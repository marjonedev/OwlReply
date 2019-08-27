class ChangeUserSubscriptionId < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :subscription_level, :subscription_id
  end
end
