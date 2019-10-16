class EmailaccountGoogleApi16102019 < ActiveRecord::Migration[5.2]
  def change
    add_column :emailaccounts, :google_access_token, :string
    add_column :emailaccounts, :google_expires_in, :bigint
    add_column :emailaccounts, :google_refresh_token, :string
  end
end
