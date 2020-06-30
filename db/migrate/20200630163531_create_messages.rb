class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.integer :emailaccount_id
      t.string :provider
      t.string :message_id
      t.boolean :fetched, default: false

      t.timestamps
    end
  end
end
