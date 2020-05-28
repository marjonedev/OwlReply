class ReplyMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :replies, :message_id, :string
  end
end
