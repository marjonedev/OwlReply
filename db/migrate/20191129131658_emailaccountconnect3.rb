class Emailaccountconnect3 < ActiveRecord::Migration[5.2]
  def change
    add_column :emailaccounts, :imap_ssl, :boolean
    remove_column :emailaccounts, :imap_encryption_type
  end
end
