class AddCustomerIdToPaymentmethods < ActiveRecord::Migration[5.2]
  def change
    add_column :paymentmethods, :customer_id, :int
  end
end
