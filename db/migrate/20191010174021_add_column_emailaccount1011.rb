class AddColumnEmailaccount1011 < ActiveRecord::Migration[5.2]
  def change
    add_column :emailaccounts, :email_provider, :string
    add_column :emailaccounts, :smtp_host, :string
    add_column :emailaccounts, :smtp_email, :string
    add_column :emailaccounts, :smtp_password, :string
    add_column :emailaccounts, :smtp_port, :string
    add_column :emailaccounts, :smtp_ssl, :boolean
  end
end
