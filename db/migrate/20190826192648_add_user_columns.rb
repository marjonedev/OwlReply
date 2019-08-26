class AddUserColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscription_level, :integer
    add_column :users, :subscription_start_date, :datetime
    add_column :users, :subscription_last_payment_date, :datetime
  end
end
