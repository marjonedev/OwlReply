class AddDateInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :date, :date
  end
end
