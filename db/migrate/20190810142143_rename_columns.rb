class RenameColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :email, :email_address
    rename_column :users, :password, :encrypted_password
  end
end
