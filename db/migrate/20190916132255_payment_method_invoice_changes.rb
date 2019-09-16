class PaymentMethodInvoiceChanges < ActiveRecord::Migration[5.2]
  def change
    change_column :invoices, :amount_paid, :integer
    change_column :invoices, :amount, :integer
    change_column :transactions, :amount, :integer
    add_column :invoices, :payment_currency, :string
    add_column :paymentmethods, :currency, :string
  end
end
