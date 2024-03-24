class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :name
      t.integer :human_id
      t.integer :job_id
      t.integer :player_type_id
      t.integer :family_id
      t.integer :guild_id
      t.timestamps
    end
  end
end
