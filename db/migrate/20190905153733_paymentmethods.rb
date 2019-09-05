class Paymentmethods < ActiveRecord::Migration[5.2]
  def change
    rename_column :paymentmethods, :customer_id, :token
    remove_column :paymentmethods, :card_brand
    remove_column :paymentmethods, :method
    remove_column :paymentmethods, :card_cvc
    remove_column :paymentmethods, :card_funding
  end
end
