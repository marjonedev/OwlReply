class Subscription2 < ActiveRecord::Migration[5.2]
  def change
    remove_column :subscriptions, :featured
    add_column :subscriptions, :recommended, :boolean, default: false
    add_column :subscriptions, :feature, :text
  end
end
