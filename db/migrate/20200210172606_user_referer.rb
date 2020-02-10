class UserReferer < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :referer, :string
  end
end
