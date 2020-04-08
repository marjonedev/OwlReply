class SkipActivationEmailAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :emailaccounts, :skip_activation, :boolean, default: false
  end
end
