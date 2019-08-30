class AddColumnPaymentMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :paymentmethods, :default, :boolean, :default => false
    add_column :paymentmethods, :card_number, :string
    add_column :paymentmethods, :card_cvc, :string
    add_column :paymentmethods, :card_exp_month, :string
    add_column :paymentmethods, :card_exp_year, :string
    remove_column :paymentmethods, :card_exp_date
  end
end
