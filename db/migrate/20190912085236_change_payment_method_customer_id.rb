class ChangePaymentMethodCustomerId < ActiveRecord::Migration[5.2]
  def change
    remove_column :paymentmethods, :customer_id
    add_column :paymentmethods, :customer_id, :string
  end
end
