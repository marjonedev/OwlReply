class ChangeUserOnEmailaccount < ActiveRecord::Migration[5.2]
  def change
    rename_column :emailaccounts, :users_id, :user_id
    change_column :emailaccounts, :user_id, :integer, null: false
  end
end
