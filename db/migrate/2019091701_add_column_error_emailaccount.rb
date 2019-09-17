class AddColumnErrorEmailaccount < ActiveRecord::Migration[5.2]
  def change
    add_column :emailaccount, :error, :string
  end
end
