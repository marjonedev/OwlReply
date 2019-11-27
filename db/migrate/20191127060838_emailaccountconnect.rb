class Emailaccountconnect < ActiveRecord::Migration[5.2]
  def change
    remove_column :emailaccounts, :connect_host
    remove_column :emailaccounts, :connect_email
    remove_column :emailaccounts, :connect_password
    remove_column :emailaccounts, :connect_port
    remove_column :emailaccounts, :connect_ssl
    add_column  :emailaccounts, :smtp_host, :string
    add_column  :emailaccounts, :smtp_port, :string
    add_column  :emailaccounts, :smtp_encryption_type, :string
  end
end
