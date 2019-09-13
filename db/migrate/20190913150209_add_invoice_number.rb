class AddInvoiceNumber < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :number, :string
  end
end
