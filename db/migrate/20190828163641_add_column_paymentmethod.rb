class AddColumnPaymentmethod < ActiveRecord::Migration[5.2]
  def change
    add_column :paymentmethods, :customer_id, :string
  end
end
