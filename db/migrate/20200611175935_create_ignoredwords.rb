class CreateIgnoredwords < ActiveRecord::Migration[5.2]
  def change
    create_table :ignoredwords do |t|
      t.integer :emailaccount_id
      t.string :word
      t.integer :user_id

      t.timestamps
    end
  end
end
