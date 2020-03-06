class UserSkip < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :skip_activation, :boolean
  end
end
