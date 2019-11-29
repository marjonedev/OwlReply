class Emailaccountconnect2 < ActiveRecord::Migration[5.2]
  def change
    remove_column  :emailaccounts, :smtp_host
    remove_column  :emailaccounts, :smtp_port
    remove_column  :emailaccounts, :smtp_encryption_type
    add_column :emailaccounts, :imap_host, :string
    add_column :emailaccounts, :imap_port, :string
    add_column :emailaccounts, :imap_encryption_type, :string
  end
end
