class ChangeIncrementColumnsEmailaccount < ActiveRecord::Migration[5.2]
  def change
    rename_column :emailaccounts, :drafts_missing_replies, :drafts_missing_replies_lifetime
    add_column :emailaccounts, :drafts_missing_replies_today, :integer
  end
end
