class AddBrandPaymentmethods < ActiveRecord::Migration[5.2]
  def change
    add_column :paymentmethods, :card_brand, :string
  end
end
