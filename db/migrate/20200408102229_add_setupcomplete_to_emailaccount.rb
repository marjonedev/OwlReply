class AddSetupcompleteToEmailaccount < ActiveRecord::Migration[5.2]
  def change
    add_column :emailaccounts, :setupcomplete, :boolean
  end
end
