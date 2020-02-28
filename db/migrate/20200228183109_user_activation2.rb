class UserActivation2 < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :active, false
  end
end
