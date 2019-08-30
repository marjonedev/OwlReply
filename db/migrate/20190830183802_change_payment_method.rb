class ChangePaymentMethod < ActiveRecord::Migration[5.2]
  def change
    remove_column :paymentmethods, :card_type
    remove_column :paymentmethods, :card_name
    add_column :paymentmethods, :card_brand, :string
    add_column :paymentmethods, :card_funding, :string
  end
end

# t.integer "user_id"
# t.string "method"
# t.string "card_name"
# t.string "card_type"
# t.string "customer_id"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.boolean "default", default: false
# t.string "card_number"
# t.string "card_cvc"
# t.string "card_exp_month"
# t.string "card_exp_year"
