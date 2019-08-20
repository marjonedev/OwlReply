class CreateReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :replies do |t|
      t.integer :emailaccount_id, :index =>true, :null => false
      t.string :keywords
      t.text :body
      t.string :negative_keywords
      t.boolean :catchcall

      t.timestamps
    end
  end
end
