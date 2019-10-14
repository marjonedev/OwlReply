class ChangeColumnEmailaccount10152019 < ActiveRecord::Migration[5.2]
  def change
    rename_column :emailaccounts, :smtp_email, :connect_email
    rename_column :emailaccounts, :smtp_host, :connect_host
    rename_column :emailaccounts, :smtp_password, :connect_password
    rename_column :emailaccounts, :smtp_port, :connect_port
    rename_column :emailaccounts, :smtp_ssl, :connect_ssl
  end
end
