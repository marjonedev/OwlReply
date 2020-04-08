class ModifyWordcounts < ActiveRecord::Migration[5.2]
  def change
    # change_table :wordcounts do |t|
    #   add_index
    #   t.references :emailaccount, foreign_key: true
    #   t.string :word
    #   t.integer :count
    #
    #   t.timestamps
    # end
    add_index :wordcounts, [:emailaccount_id,:word]
    add_index :wordcounts, [:emailaccount_id,:count]
  end
end
