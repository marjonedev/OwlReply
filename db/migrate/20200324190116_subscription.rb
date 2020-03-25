class Subscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :featured, :boolean, default: false
  end
end
