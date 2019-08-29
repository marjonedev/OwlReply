class CreatePaymentmethods < ActiveRecord::Migration[5.2]
  def change
    create_table :paymentmethods do |t|
      t.integer :user_id
      t.string :method
      t.string :card_name
      t.string :card_type
      t.string :customer_id
      t.date :card_exp_date

      t.timestamps
    end
  end
end
