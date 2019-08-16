class CreateEmailaccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :emailaccounts do |t|
      t.references :user, index: true, null: false
      t.string :address
      t.string :password
      t.string :encrypted_password
      t.string :encryption_key

      t.timestamps
    end
  end
end
