class AddSubscriptionInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :subscription_id, :integer
  end
end
