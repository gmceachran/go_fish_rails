class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.integer :state, default: 0, null: false
      t.integer :max_players, default: 5, null: false
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
