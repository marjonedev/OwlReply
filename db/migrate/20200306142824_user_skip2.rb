class UserSkip2 < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :skip_activation, false
  end
end
