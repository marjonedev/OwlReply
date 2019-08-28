class AddColumnsEmailaccount < ActiveRecord::Migration[5.2]
  def change
    add_column :emailaccounts, :drafts_created_today, :integer
    add_column :emailaccounts, :drafts_created_lifetime, :integer
    add_column :emailaccounts, :template, :text
    add_column :replies, :drafts_created_today, :integer
    add_column :replies, :drafts_created_lifetime, :integer
  end
end
