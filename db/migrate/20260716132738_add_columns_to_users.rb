class AddColumnsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :country, :string
    add_column :users, :state, :string
  end
end
