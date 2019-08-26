class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.string :reference
      t.string :payment_provider
      t.timestamp :timestamp
      t.boolean :reversed
      t.float :amount

      t.timestamps
    end
  end
end
