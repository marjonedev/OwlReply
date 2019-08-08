class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password
      t.string :salt

      t.timestamps
    end
    add_index :users, :email
  end
end
