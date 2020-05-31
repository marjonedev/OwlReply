class RemoveMessageId < ActiveRecord::Migration[5.2]
  def change
    remove_column :replies, :message_id
  end
end
