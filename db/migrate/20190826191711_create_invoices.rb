class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.integer :user_id, :index =>true, :null => false
      t.float :amount
      t.float :amount_paid
      t.datetime :date_paid
      t.integer :transaction_id

      t.timestamps
    end
  end
end
