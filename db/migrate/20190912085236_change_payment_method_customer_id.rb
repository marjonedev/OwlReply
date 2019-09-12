class ChangePaymentMethodCustomerId < ActiveRecord::Migration[5.2]
  def change
    remove_column :customer_id
    add_column :customer_id, :string
  end
end
