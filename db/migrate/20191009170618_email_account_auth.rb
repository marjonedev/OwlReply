class EmailAccountAuth < ActiveRecord::Migration[5.2]
  def change
    add_column :emailaccounts, :authenticated, :boolean, default: false
  end
end
