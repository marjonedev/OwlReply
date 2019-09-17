class AddColumnErrorEmailaccount < ActiveRecord::Migration[5.2]
  def change
    add_column :emailaccounts, :error, :string
  end
end
