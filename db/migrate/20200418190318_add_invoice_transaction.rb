class AddInvoiceTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :invoice_id, :integer, null: false
  end
end
