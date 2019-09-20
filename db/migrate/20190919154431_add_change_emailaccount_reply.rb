class AddChangeEmailaccountReply < ActiveRecord::Migration[5.2]
  def change
    add_column :emailaccounts, :drafts_missing_replies, :integer
    add_column :replies, :search, :string
  end
end
