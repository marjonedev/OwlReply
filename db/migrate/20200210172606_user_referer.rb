class UserReferer < ActiveRecord::Migration[5.2]
  def change
    add_column :user, :referer, :string
  end
end
