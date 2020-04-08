class CreateWordcounts < ActiveRecord::Migration[5.2]
  def change
    create_table :wordcounts do |t|
      t.references :emailaccount, foreign_key: true
      t.string :word
      t.integer :count

      t.timestamps
    end
  end
end
