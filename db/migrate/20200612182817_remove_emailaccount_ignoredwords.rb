class RemoveEmailaccountIgnoredwords < ActiveRecord::Migration[5.2]
  def change
    remove_column :ignoredwords, :emailaccount_id
  end
end
