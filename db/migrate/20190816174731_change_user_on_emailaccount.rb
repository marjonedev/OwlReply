class ChangeUserOnEmailaccount < ActiveRecord::Migration[5.2]
  def change
    change_column :emailaccounts, :user_id, :integer, null: false
  end
end
