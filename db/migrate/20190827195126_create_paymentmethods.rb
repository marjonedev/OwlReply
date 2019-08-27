class CreatePaymentmethods < ActiveRecord::Migration[5.2]
  def change
    create_table :paymentmethods do |t|
      t.integer :user_id
      t.string :method
      t.string :card_name
      t.datetime :card_expiration_date
      t.string :card_type

      t.timestamps
    end
  end
end
